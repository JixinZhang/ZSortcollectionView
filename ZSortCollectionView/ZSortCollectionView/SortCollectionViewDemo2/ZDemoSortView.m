//
//  ZDemoSortView.m
//  ZSortCollectionView
//
//  Created by ZhangBob on 07/07/2017.
//  Copyright © 2017 Jixin. All rights reserved.
//

#import "ZDemoSortView.h"
#import "ZSortCollectionView.h"
#import "ZDemoCollectionViewCell.h"

#define KScreenSize         ([[UIScreen mainScreen] bounds].size)
#define KScreenWidth        ([[UIScreen mainScreen] bounds].size.width)
#define KScreenHeight       ([[UIScreen mainScreen] bounds].size.height)

#define kUIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@interface ZDemoSortView()<ZSortCollectionViewDelegate, ZSortCollectionViewDataSource>

@property (nonatomic, strong) ZSortCollectionView        *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) UIView                     *headerView;
@property (nonatomic, strong) UIButton                   *doneButton;

@property (nonatomic, strong) NSArray                    *data;


@end

@implementation ZDemoSortView{
    UICollectionViewCell *__collectionViewCell;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.headerView];
        [self addSubview:self.collectionView];
        [self addSubview:self.doneButton];
        [self __setup];
    }
    return self;
}

- (void) __setup {
    [self registerCollectionViewCell];
    [self.collectionView reloadData];
}

- (void) registerCollectionViewCell{
    [self.collectionView registerClass:[ZDemoCollectionViewCell class]
            forCellWithReuseIdentifier:NSStringFromClass([ZDemoCollectionViewCell class])];
}

#pragma mark - Getter

- (NSArray *)data{
    if (!_data) {
        NSMutableArray *temp = @[].mutableCopy;
        NSArray *colors = @[[UIColor redColor], [UIColor brownColor], [UIColor yellowColor], [UIColor orangeColor], [UIColor greenColor]];
        for (int i = 0; i < 5; i ++) {
            NSMutableArray *tempSection = @[].mutableCopy;
            for (int j = 0; j < arc4random() % 12 + 6; j ++) {
                NSString *str = [NSString stringWithFormat:@"%d--%d", i, j];
                ZDemoCellModel *model = [ZDemoCellModel new];
                model.backGroundColor = colors[i];
                model.title = str;
                [tempSection addObject:model];
            }
            [temp addObject:tempSection.copy];
        }
        _data = temp.copy;
    }
    return _data;
}

- (ZSortCollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[ZSortCollectionView alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.bounds),CGRectGetHeight(self.bounds)-64-50)
                                                collectionViewLayout:[self flowLayout]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = YES;
        _collectionView.contentInset = UIEdgeInsetsZero;
        
        _collectionView.onlyFirstSectionCanSort = NO;
        _collectionView.allowMoveCellSpanSection = YES;
        _collectionView.backgroundColor = [UIColor whiteColor];
        
        //设置cell被拖走后原位置的view
        UIView *cellBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        cellBgView.backgroundColor = kUIColorFromRGB(0xF0F0F0);
        _collectionView.cellBgView = cellBgView;
    }
    return  _collectionView;
}

- (UICollectionViewFlowLayout *) flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumLineSpacing = 15;
        _flowLayout.minimumInteritemSpacing = 5;
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 15, 20, 15);
        _flowLayout.itemSize = CGSizeMake(50, 25);
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return _flowLayout;
}

- (UIButton *) doneButton {
    if (!_doneButton) {
        _doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0 , KScreenHeight - 50, KScreenWidth, 50)];
        [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _doneButton.backgroundColor = kUIColorFromRGB(0x1428F0);
        _doneButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [_doneButton setTitle:@"完 成" forState:UIControlStateNormal];
        [_doneButton addTarget:self action:@selector(doneButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}

- (UIView *) headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 64)];
        _headerView.backgroundColor = [UIColor clearColor];
        [_headerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideAction:)]];
    }
    return _headerView;
}

#pragma mark -- Action

- (void) hideAction:(id) sender {
    !self.hideBlock?:self.hideBlock();
}

- (IBAction)doneButtonClicked:(id)sender {
    !self.doneBlock?:self.doneBlock();
}

#pragma mark -- UICollectionViewDelegate


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.data.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.data[section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ZDemoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZDemoCollectionViewCell class]) forIndexPath:indexPath];
    
    ZDemoCellModel *item = self.data[indexPath.section][indexPath.item];
    cell.label.text = item.title;
    cell.backgroundColor = item.backGroundColor;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

//ZSortCollectionView获取dataSource
- (NSArray *)dataSourceArrayOfCollectionView:(ZSortCollectionView *)collectionView {
    return _data;
}

#pragma mark - ZSortCellCollectionViewDelegate

//ZSortCollectionView更新当前collection的dataSource
- (void)sortCellCollectionView:(ZSortCollectionView *)collectionView newDataArrayAfterMoved:(NSArray *)newDataArray {
    self.data = [NSMutableArray arrayWithArray:newDataArray];
}

//设定不可以移动的cell
- (NSArray<NSIndexPath *> *)excludeIndexPathsWhenMoveSortCellCollectionView:(ZSortCollectionView *)collectionView {
    NSMutableArray * excluedeIndexPaths = [NSMutableArray array];
    [self.data.firstObject enumerateObjectsUsingBlock:^(ZDemoCellModel*  _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        
    }];
    return excluedeIndexPaths.copy;
}

//will Begin Move
- (void)sortCellCollectionView:(ZSortCollectionView *)collectionView cellWillBeginMoveAtIndexPath:(NSIndexPath *)indexPath {
    
}

//Cell is Moving
- (void)sortCellCollectionViewCellisMoving:(ZSortCollectionView *)collectionView {
    
}

//Cell End Moving
- (void)sortCellCollectionViewCellEndMoving:(ZSortCollectionView *)collectionView {
    
}

//cell's position exchanged
- (void)sortCellCollectionView:(ZSortCollectionView *)collectionView moveCellFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
}


//UIPanGestureRecognizer end
- (void)sortCellCollectionViewEndMoving:(ZSortCollectionView *)collectionView moveCellFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
}


@end
