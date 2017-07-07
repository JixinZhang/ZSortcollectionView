//
//  ZSortCollectionView.h
//  WeexDemo
//
//  Created by ZhangBob on 07/07/2017.
//  Copyright © 2017 Jixin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZSortCollectionView;

@protocol ZSortCollectionViewDelegate <UICollectionViewDelegate>

@required

/**
 当数据源更新的时候调用，必须实现，需将新的数据源设置为当前collectionView的数据源

 @param collectionView 发起这个请求的collectionView
 @param newDataArray 新的数据源
 */
- (void)sortCellCollectionView:(ZSortCollectionView *)collectionView
        newDataArrayAfterMoved:(NSArray *)newDataArray;

@optional

- (NSArray<NSIndexPath *> *)excludeIndexPathsWhenMoveSortCellCollectionView:(ZSortCollectionView *)collectionView;

/**
 当某个cell将要开始移动的时候调用

 @param collectionView 发起这个请求的collectionView
 @param indexPath 该cell当前的indexPath
 */
- (void)sortCellCollectionView:(ZSortCollectionView *)collectionView
  cellWillBeginMoveAtIndexPath:(NSIndexPath *)indexPath;

/**
 cell正在移动

 @param collectionView 发起这个请求的collectionView
 */
- (void)sortCellCollectionViewCellisMoving:(ZSortCollectionView *)collectionView;

/**
 cell移动停止，并且成功移动到新的位置

 @param collectionView 发起这个请求的collectionView
 */
- (void)sortCellCollectionViewCellEndMoving:(ZSortCollectionView *)collectionView;

/**
 成功交换了位置，但手指仍在屏幕上，可以继续拖动来交换位置

 @param collectionView 发起这个请求的collectionView
 @param fromIndexPath 交换cell的起始位置
 @param toIndexPath 交换cell的结束位置
 */
- (void)sortCellCollectionView:(ZSortCollectionView *)collectionView
         moveCellFromIndexPath:(NSIndexPath *)fromIndexPath
                   toIndexPath:(NSIndexPath *)toIndexPath;

/**
 手指离开屏幕，拖动取消或者结束

 @param collectionView 发起这个请求的collectionView
 @param fromIndexPath 交换cell的起始位置
 @param toIndexPath 交换cell的结束位置
 */
- (void)sortCellCollectionViewEndMoving:(ZSortCollectionView *)collectionView
                  moveCellFromIndexPath:(NSIndexPath *)fromIndexPath
                            toIndexPath:(NSIndexPath *)toIndexPath;

@end

@protocol ZSortCollectionViewDataSource <UICollectionViewDataSource>

@required

/**
 返回整个CollectionView的数据，必须实现，需根据数据进行移动后的数据重排
 */
- (NSArray *)dataSourceArrayOfCollectionView:(ZSortCollectionView *)collectionView;

@end


@interface ZSortCollectionView : UICollectionView

@property (nonatomic, weak) id<ZSortCollectionViewDelegate> delegate;
@property (nonatomic, weak) id<ZSortCollectionViewDataSource> dataSource;

/**
 cell拖动时，留在原处的背景view，若没有定制则隐藏cell；
 cellBgView的背景色alpha值必须为1。
 */
@property (nonatomic, strong) UIView *cellBgView;

/*
 是否允许拖拽的cell跨越组, 默认 NO
 */
@property (nonatomic, assign, getter=isAllowMoveCellSpanSection) BOOL allowMoveCellSpanSection;

/**
 是否只允许section 0 可以拖拽排序, 默认为YES
 */
@property (nonatomic, assign, getter=isOnlyFirstSectionCanSort) BOOL onlyFirstSectionCanSort;

/**
 是否限定为，仅在cell所在的section中移动，默认为NO，即不限定
 */
@property (nonatomic, assign, getter=isOnlyMoveInSection) BOOL onlyMoveInSection;

/*
 是否正在编辑模式，调用sort_enterEditingModel和sort_stopEditingModel会修改该方法的值
 */
@property (nonatomic, assign, readonly, getter=isEditing) BOOL editing;

/*
 进入编辑模式
 */
- (void)sort_enterEditingModel;

/*
 退出编辑模式
 */
- (void)sort_stopEditingModel;

/**
 从section0中删除某个cell，并添加到section1的最后面
 务必确保有两个section

 @param deleteIndexPath 删除cell的indexPath
 */
- (void)deleteCellWithIndexPath:(NSIndexPath *)deleteIndexPath;

/**
 从section1中删除某个cell，并将其添加到section0的最后

 @param addIndexPath 添加cell的indexPath
 */
- (void)addCellWithIndexPath:(NSIndexPath *)addIndexPath;

/**
 cell移动到另一个indexPath中
 下面两个方法是此方法的特殊情况
 - (void)deleteCellWithIndexPath:(NSIndexPath *)deleteIndexPath;
 - (void)addCellWithIndexPath:(NSIndexPath *)addIndexPath;
 @param fromIndexPath 需要移动cell的indexPath
 @param toIndexPath 移动cell到目标indexPath
 */
- (void)moveCellWithFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;

@end
