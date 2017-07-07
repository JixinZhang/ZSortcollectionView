//
//  ZChannelsCollectionViewCell.h
//  MCommonUI
//
//  Created by ZhangBob on 07/07/2017.
//  Copyright © 2017 Jixin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZChannelsCollectionViewCell : UICollectionViewCell

@property (nonatomic, assign) BOOL isSorting;
@property (nonatomic, assign) BOOL isMain;
@property (nonatomic, assign) BOOL isSortSelected;

@property (nonatomic, copy) void (^deleteBlock)(id content);
@property (nonatomic, copy) void (^addBlock)(id content);

- (void) z_doSetContentData:(id) content;

- (void) z_canEditable:(BOOL) editable;

@end
