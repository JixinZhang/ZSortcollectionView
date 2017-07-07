//
//  ZChannelsSortView.m
//  MCommonUI
//
//  Created by ZhangBob on 07/07/2017.
//  Copyright © 2017 Jixin. All rights reserved.
//

#import "ZChannelsSortView.h"
#import "ZChannelsHeaderReusableView.h"
#import "ZChannelsCollectionViewCell.h"
#import "ZSortCollectionView.h"

#define KScreenSize         ([[UIScreen mainScreen] bounds].size)
#define KScreenWidth        ([[UIScreen mainScreen] bounds].size.width)
#define KScreenHeight       ([[UIScreen mainScreen] bounds].size.height)

#define kUIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

static NSString *const HeaderIdentifier = @"HeaderIdentifier";

@interface ZChannelsSortView()<ZSortCollectionViewDelegate, ZSortCollectionViewDataSource>

@property (nonatomic, strong) ZSortCollectionView        *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) UIView                     *headerView;
@property (nonatomic, strong) UIButton                   *doneButton;

@property (nonatomic, strong) NSMutableArray             *sections;
@property (nonatomic, strong) NSArray                    *sectionChannels;

@end

@implementation ZChannelsSortView {
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
    self.sections = [NSMutableArray arrayWithObjects:@"已选频道",@"未选频道", nil];
    [self registerCollectionViewCell];
    [self.collectionView reloadData];
}

- (void) registerCollectionViewCell{
    [self.collectionView registerClass:[ZChannelsCollectionViewCell class]
            forCellWithReuseIdentifier:NSStringFromClass([ZChannelsCollectionViewCell class])];
    [self.collectionView registerClass:[ZChannelsHeaderReusableView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:NSStringFromClass([ZChannelsHeaderReusableView class])];
}

- (void) setChannels:(ZChannels *)channels{
    _channels = channels;
    NSMutableArray* pickedChannels = [NSMutableArray arrayWithArray:channels.pickedChannels];
    NSMutableArray* unpickedChannels = [NSMutableArray arrayWithArray:channels.unpickedChannels];
    self.sectionChannels = [NSArray arrayWithObjects:pickedChannels,unpickedChannels, nil];
    [self.collectionView reloadData];
}

#pragma mark -- Getter

- (ZSortCollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[ZSortCollectionView alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.bounds),CGRectGetHeight(self.bounds)-64-50)
                                                collectionViewLayout:[self flowLayout]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = kUIColorFromRGB(0xFFFFFF);
        _collectionView.showsVerticalScrollIndicator = YES;
        _collectionView.contentInset = UIEdgeInsetsZero;
        
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
        _flowLayout.itemSize = CGSizeMake(80, 35);
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

- (void)setOnlyMoveInSection:(BOOL)onlyMoveInSection {
    _onlyMoveInSection = onlyMoveInSection;
    self.collectionView.onlyMoveInSection = onlyMoveInSection;
}

#pragma mark -- Action

- (void) hideAction:(id) sender {
    !self.hideBlock?:self.hideBlock();
}

- (IBAction)doneButtonClicked:(id)sender {
    if (self.doneBlock){
        for (ZChannelModel *item in self.sectionChannels.firstObject) {
            item.picked = YES;
        }
        for (ZChannelModel* item in self.sectionChannels.lastObject) {
            item.picked = NO;
        }
        if ([self.sectionChannels.firstObject count] == 0){
//            [HUITip showWithText:@"至少需要一个频道"];
            return;
        }
        self.channels.pickedChannels = [NSArray arrayWithArray:self.sectionChannels.firstObject];
        self.channels.unpickedChannels = [NSArray arrayWithArray:self.sectionChannels.lastObject];
        self.doneBlock();
    }
}

#pragma mark -- UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(100, 57);
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.sectionChannels[section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ZChannelsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZChannelsCollectionViewCell class]) forIndexPath:indexPath];
    
    ZChannelModel *item = self.sectionChannels[indexPath.section][indexPath.item];
    [cell z_doSetContentData:item.displayName];
    cell.isMain = item.sticky;
    [cell z_canEditable:indexPath.section == 0];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableView;
    if (UICollectionElementKindSectionHeader == kind) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                          withReuseIdentifier:NSStringFromClass([ZChannelsHeaderReusableView class])
                                                                 forIndexPath:indexPath];
        [((ZChannelsHeaderReusableView *)reusableView) z_setNameContent: [self.sections objectAtIndex:indexPath.section]];
        [((ZChannelsHeaderReusableView *)reusableView) z_setDetailContent: (0 == indexPath.section) ? @"请拖动排序" : @"" ];
    }
    
    return reusableView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

//ZSortCollectionView获取dataSource
- (NSArray *)dataSourceArrayOfCollectionView:(ZSortCollectionView *)collectionView {
    return _sectionChannels;
}

#pragma mark - ZSortCellCollectionViewDelegate

//ZSortCollectionView更新当前collection的dataSource
- (void)sortCellCollectionView:(ZSortCollectionView *)collectionView newDataArrayAfterMoved:(NSArray *)newDataArray {
    self.sectionChannels = [NSMutableArray arrayWithArray:newDataArray];
}

//设定不可以移动的cell
- (NSArray<NSIndexPath *> *)excludeIndexPathsWhenMoveSortCellCollectionView:(ZSortCollectionView *)collectionView {
    NSMutableArray * excluedeIndexPaths = [NSMutableArray array];
    [self.sectionChannels.firstObject enumerateObjectsUsingBlock:^(ZChannelModel*  _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        if (item.sticky) {
            [excluedeIndexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:0]];
        }
    }];
    return excluedeIndexPaths.copy;
}

//will Begin Move
- (void)sortCellCollectionView:(ZSortCollectionView *)collectionView cellWillBeginMoveAtIndexPath:(NSIndexPath *)indexPath {
    ZChannelModel *value = [[self.sectionChannels objectAtIndex:indexPath.section]  objectAtIndex:indexPath.item];
    if (!value.sticky){
        __collectionViewCell = [self.collectionView cellForItemAtIndexPath:indexPath];
        ((ZChannelsCollectionViewCell *)__collectionViewCell).isSorting = YES;
    }
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
    ZChannelModel *value = [[self.sectionChannels objectAtIndex:toIndexPath.section]  objectAtIndex:toIndexPath.item];
    if (!value.sticky){
        __collectionViewCell = [self.collectionView cellForItemAtIndexPath:toIndexPath];
        ((ZChannelsCollectionViewCell *)__collectionViewCell).isSorting = NO;
    }
}

@end
