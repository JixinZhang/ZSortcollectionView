//
//  ZSortCollectionView.m
//  WeexDemo
//
//  Created by ZhangBob on 07/07/2017.
//  Copyright © 2017 Jixin. All rights reserved.
//

#import "ZSortCollectionView.h"

@interface ZSortCollectionView() <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSIndexPath *originalIndexPath;
@property (nonatomic, strong) NSIndexPath *moveIndexPath;

@property (nonatomic, strong) NSIndexPath *originalIndexPathEnd;
@property (nonatomic, strong) NSIndexPath *moveIndexPathEnd;

@property (nonatomic, strong) CADisplayLink *edgeTimer;
@property (nonatomic, assign) CGPoint lastPoint;

@property (nonatomic, strong) UICollectionViewCell *originEditCell;

@property (nonatomic, weak) UIView *tempMoveCell;
@property (nonatomic, weak) UIPanGestureRecognizer *panGesture;

@end

@implementation ZSortCollectionView

@dynamic delegate;
@dynamic dataSource;

- (void)dealloc {
    
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self initializeProperty];
        [self sort_addPanGesture];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeProperty];
        [self sort_addPanGesture];
            }
    return self;
}

- (void)initializeProperty {
    _allowMoveCellSpanSection = NO;
    _onlyFirstSectionCanSort = YES;
    _onlyMoveInSection = NO;
}

#pragma mark - panGesture methods

/**
 添加拖拽手势
 */
- (void)sort_addPanGesture {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(sort_panGesture:)];
    _panGesture = pan;
    [self addGestureRecognizer:pan];
}

- (void)sort_panGesture:(UIPanGestureRecognizer *)pan {
    if (!pan) {
        return;
    }
    if (pan.state == UIGestureRecognizerStateBegan) {
        [self sort_gestureBegin:pan];
    }
    else if (pan.state == UIGestureRecognizerStateChanged) {
        [self sort_gestureChange:pan];
    }
    else if (pan.state == UIGestureRecognizerStateEnded ||
             pan.state == UIGestureRecognizerStateCancelled) {
        [self sort_gestureEndOrCancel:pan];
    }
}

/**
 手势开始
 */
- (void)sort_gestureBegin:(UIGestureRecognizer *)panGesture {
    //获取手指所在的cell
    CGPoint point = [panGesture locationOfTouch:0 inView:panGesture.view];
    _originalIndexPath = [self indexPathForItemAtPoint:point];
    if ([self sort_indexPathIsExcluded:_originalIndexPath]) {
        return;
    }
    
    if (_onlyFirstSectionCanSort == YES) {
        if (_originalIndexPath.section != 0) {
            return;
        }
    }
    self.originalIndexPathEnd = _originalIndexPath;
    //通知代理
    if ([self.delegate respondsToSelector:@selector(sortCellCollectionView:cellWillBeginMoveAtIndexPath:)]) {
        [self.delegate sortCellCollectionView:self cellWillBeginMoveAtIndexPath:_originalIndexPath];
    }
    
    UICollectionViewCell *cell = [self cellForItemAtIndexPath:_originalIndexPath];
    self.originEditCell = cell;
    UIImageView *snapshotImageView = [[UIImageView alloc] initWithFrame:cell.bounds];
    snapshotImageView.image = [self sort_captureImageWithView:cell];
    UIView *tempMoveCell = [cell snapshotViewAfterScreenUpdates:NO];
    [tempMoveCell addSubview:snapshotImageView];
    //添加阴影
    tempMoveCell.layer.shadowColor = [UIColor blackColor].CGColor;
    tempMoveCell.layer.shadowOffset = CGSizeMake(-1, 0);
    tempMoveCell.layer.shadowOpacity = 0.4;
    
    if (self.cellBgView) {
        UIView *bgView = self.cellBgView;
        bgView.frame = cell.bounds;
        bgView.tag = 1010101010;
        [cell addSubview:bgView];
    } else {
        cell.hidden = YES;
    }
    
    _tempMoveCell = tempMoveCell;
    _tempMoveCell.frame = cell.frame;

    [self addSubview:_tempMoveCell];
    
    _lastPoint = [panGesture locationOfTouch:0 inView:panGesture.view];
    [self sort_enterEditingModel];
}

/**
 手势拖动
 */
- (void)sort_gestureChange:(UIGestureRecognizer *)panGesture {
    //通知代理
    if ([self.delegate respondsToSelector:@selector(sortCellCollectionViewCellisMoving:)]) {
        [self.delegate sortCellCollectionViewCellisMoving:self];
    }
    if (self.isOnlyMoveInSection) {
        //cell仅可以在其所在的section中移动
        
        CGPoint panPoint = [panGesture locationOfTouch:0 inView:panGesture.view];
        _lastPoint = panPoint;
        
        CGRect firstSectionFrame = [self firstSectionFrame];
        CGFloat limitMiniY = CGRectGetMinY(firstSectionFrame) + CGRectGetHeight(_tempMoveCell.frame) / 2.0 ;
        
        CGRect lastCellFrameInFirstSection = [self lastCellFrameInFirstSection];
        CGFloat limitMaxY = CGRectGetMaxY(lastCellFrameInFirstSection) + CGRectGetHeight(_tempMoveCell.frame) / 2.0;
        if (panPoint.y > limitMaxY) {
            panPoint = CGPointMake(panPoint.x, limitMaxY);
        } else if (panPoint.y < limitMiniY) {
            panPoint = CGPointMake(panPoint.x, limitMiniY);
        }
        _tempMoveCell.center = panPoint;
    } else {
        //cell可在屏幕的任何地方移动
        CGFloat tranX = [panGesture locationOfTouch:0 inView:panGesture.view].x - _lastPoint.x;
        CGFloat tranY = [panGesture locationOfTouch:0 inView:panGesture.view].y - _lastPoint.y;
        _tempMoveCell.center = CGPointApplyAffineTransform(_tempMoveCell.center, CGAffineTransformMakeTranslation(tranX, tranY));
        _lastPoint = [panGesture locationOfTouch:0 inView:panGesture.view];
    }
    
    [self sort_moveCell];
}

/**
 手势取消或者结束
 */
- (void)sort_gestureEndOrCancel:(UIGestureRecognizer *)panGesture {
    self.userInteractionEnabled = NO;
    
    if ([self.delegate respondsToSelector:@selector(sortCellCollectionViewCellEndMoving:)]) {
        [self.delegate sortCellCollectionViewCellEndMoving:self];
    }
    
    if ([self.delegate respondsToSelector:@selector(sortCellCollectionViewEndMoving:moveCellFromIndexPath:toIndexPath:)]) {
        [self.delegate sortCellCollectionViewEndMoving:self moveCellFromIndexPath:self.originalIndexPathEnd toIndexPath:self.moveIndexPathEnd];
    }
    self.originalIndexPathEnd = nil;
    self.moveIndexPathEnd = nil;
    UICollectionViewCell *cell = [self cellForItemAtIndexPath:_originalIndexPath];
    if (cell == nil) {
        cell = self.originEditCell;
    }
    [UIView animateWithDuration:0.25 animations:^{
        _tempMoveCell.center = cell.center;
    } completion:^(BOOL finished) {
        [_tempMoveCell removeFromSuperview];
        cell.hidden = NO;
        UIView *bgView = [cell viewWithTag:1010101010];
        if (bgView) {
            [bgView removeFromSuperview];
        }
        self.userInteractionEnabled = YES;
        self.originEditCell = nil;
    }];
    [self sort_stopEditingModel];
}

#pragma mark - setter 


#pragma mark - private methods

- (void)sort_moveCell {
    for (UICollectionViewCell *cell in [self visibleCells]) {
        if ([self indexPathForCell:cell] == _originalIndexPath ||
            [self sort_indexPathIsExcluded:[self indexPathForCell:cell]]) {
            continue;
        }
        //计算中心距
        CGFloat spacingX = fabs(_tempMoveCell.center.x - cell.center.x);
        CGFloat spacingY = fabs(_tempMoveCell.center.y - cell.center.y);
        if (spacingX <= _tempMoveCell.bounds.size.width / 2.0f && spacingY <= _tempMoveCell.bounds.size.height / 2.0f) {
            //不允许跨越组
            if (!self.isAllowMoveCellSpanSection) {
                if ([self indexPathForCell:cell].section != _originalIndexPath.section) {
                    return;
                }
            }
            _moveIndexPath = [self indexPathForCell:cell];
            self.moveIndexPathEnd = _moveIndexPath;
            
            //更新数据源并开始移动动画
            [self moveCellAnimation];
            break;
        } else {
            self.moveIndexPathEnd = _originalIndexPath;
        }
    }
}

- (BOOL)sort_updateDataSource {
    NSMutableArray *temp = [self getCollectionDataSource].mutableCopy;
    //判断数据源是单个数组(CollectionView只有一个section)，还是数组嵌套数组(CollectionView有多个section)
    //dataTypeCheck = YES 表示数组嵌套数组
    BOOL dataTypeCheck =  ([self numberOfSections] != 1 || ([self numberOfSections] == 1 && [temp[0] isKindOfClass:[NSArray class]]));

    if (_moveIndexPath.section == _originalIndexPath.section) {
        //在同一个section中移动
        NSMutableArray *originalSection = dataTypeCheck ? temp[_originalIndexPath.section] : temp;
        if (_moveIndexPath.item > _originalIndexPath.item) {
            //向后移动
            for (NSUInteger idx = _originalIndexPath.item; idx < _moveIndexPath.item; idx++) {
                if (originalSection.count <= idx + 1) {
                    return NO;
                }
                [originalSection exchangeObjectAtIndex:idx withObjectAtIndex:idx + 1];
            }
        } else {
            //向前移动
            for (NSUInteger idx = _originalIndexPath.item; idx > _moveIndexPath.item; idx--) {
                if (idx == 0) {
                    return NO;
                }
                [originalSection exchangeObjectAtIndex:idx withObjectAtIndex:idx - 1];
            }
        }
    } else {
        //在不同的section中移动
        NSMutableArray *originalSection = temp[_originalIndexPath.section];
        NSMutableArray *currentSection = temp[_moveIndexPath.section];
        [currentSection insertObject:originalSection[_originalIndexPath.item] atIndex:_moveIndexPath.item];
        [originalSection removeObjectAtIndex:_originalIndexPath.item];
    }
    
    //将重新排好的数据传递给外部
    if ([self.delegate respondsToSelector:@selector(sortCellCollectionView:newDataArrayAfterMoved:)]) {
        [self.delegate sortCellCollectionView:self newDataArrayAfterMoved:[temp copy]];
    }
    return YES;
}

- (BOOL)sort_indexPathIsExcluded:(NSIndexPath *)indexPath {
    if (!indexPath || ![self.delegate respondsToSelector:@selector(excludeIndexPathsWhenMoveSortCellCollectionView:)]) {
        return NO;
    }
    NSArray<NSIndexPath *> *excludeIndexPaths = [self.delegate excludeIndexPathsWhenMoveSortCellCollectionView:self];
    __block BOOL flag = NO;
    [excludeIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.item == indexPath.item && obj.section == indexPath.section) {
            flag = YES;
            *stop = YES;
        }
    }];
    return flag;
}

- (CGRect) lastCellFrameInFirstSection{
    NSMutableArray *temp = [self getCollectionDataSource].mutableCopy;
    NSArray *section0 = [NSArray arrayWithArray:temp.firstObject];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:section0.count - 1 inSection:0];
    
    UICollectionViewCell *lastCell = [self cellForItemAtIndexPath:indexPath];
    CGRect rect = [lastCell frame];
    return rect;
}

- (CGRect) lastSectionFrame{
    NSMutableArray *temp = [self getCollectionDataSource].mutableCopy;

    if (temp.count <= 1) {
        return [self lastCellFrameInFirstSection];
    } else {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:1];
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryElementOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
        CGRect rect = [attributes frame];
        return rect;
    }
}

- (CGRect) firstSectionFrame{
    NSMutableArray *temp = [self getCollectionDataSource].mutableCopy;
    if (temp.count == 0) {
        return self.frame;
    } else {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryElementOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
        CGRect rect = [attributes frame];
        return rect;
    }
}

- (NSMutableArray *)getCollectionDataSource {
    NSMutableArray *temp = @[].mutableCopy;
    if ([self.dataSource respondsToSelector:@selector(dataSourceArrayOfCollectionView:)]) {
        [temp addObjectsFromArray:[self.dataSource dataSourceArrayOfCollectionView:self]];
    }
    //判断数据源是单个数组(CollectionView只有一个section)，还是数组嵌套数组(CollectionView有多个section)
    //dataTypeCheck = YES 表示数组嵌套数组
    BOOL dataTypeCheck =  ([self numberOfSections] != 1 || ([self numberOfSections] == 1 && [temp[0] isKindOfClass:[NSArray class]]));
    if (dataTypeCheck) {
        for (int i = 0; i < temp.count; i ++) {
            [temp replaceObjectAtIndex:i withObject:[temp[i] mutableCopy]];
        }
    }
    return temp;
}

#pragma mark - public methods 

- (void)sort_enterEditingModel {
    _editing = YES;
}

- (void)sort_stopEditingModel {
    _editing = NO;
}

- (void)deleteCellWithIndexPath:(NSIndexPath *)deleteIndexPath {
    _originalIndexPath = deleteIndexPath;
    [self moveCellWithFromIndexPath:deleteIndexPath toIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]];
}

- (void)addCellWithIndexPath:(NSIndexPath *)addIndexPath {
    NSMutableArray *temp = [self getCollectionDataSource].mutableCopy;
    NSArray *section0 = temp[0];
    [self moveCellWithFromIndexPath:addIndexPath toIndexPath:[NSIndexPath indexPathForItem:section0.count inSection:0]];
}

- (void)moveCellWithFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    if ([self sort_indexPathIsExcluded:_originalIndexPath]) {
        return;
    }

    _originalIndexPath = fromIndexPath;
    _moveIndexPath = toIndexPath;
    [self moveCellAnimation];
}

- (void)moveCellAnimation {
    //更新数据源
    if (![self sort_updateDataSource]) {
        //如果更新数据源失败，则不做任何操作
        return;
    }
    //移动
    [CATransaction begin];
    [self moveItemAtIndexPath:_originalIndexPath toIndexPath:_moveIndexPath];
    [CATransaction setCompletionBlock:^{
        
    }];
    [CATransaction commit];
    //通知代理
    if ([self.delegate respondsToSelector:@selector(sortCellCollectionView:moveCellFromIndexPath:toIndexPath:)]) {
        [self.delegate sortCellCollectionView:self moveCellFromIndexPath:_originalIndexPath toIndexPath:_moveIndexPath];
    }
    //设置移动后的起始indexPath
    _originalIndexPath = _moveIndexPath;
}

#pragma mark - overWrite methods

/**
 *  重写hitTest事件，判断是否应该相应自己的滑动手势，还是系统的滑动手势
 */

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    _panGesture.enabled = [self indexPathForItemAtPoint:point];
    return [super hitTest:point withEvent:event];
}

#pragma mark - Utilis

- (UIImage *)sort_captureImageWithView:(UIView *)view{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
