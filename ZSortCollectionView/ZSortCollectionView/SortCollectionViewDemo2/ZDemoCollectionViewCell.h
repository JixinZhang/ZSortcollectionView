//
//  ZDemoCollectionViewCell.h
//  ZSortCollectionView
//
//  Created by ZhangBob on 07/07/2017.
//  Copyright © 2017 Jixin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZDemoCellModel : NSObject

@property (nonatomic, strong) UIColor *backGroundColor;
@property (nonatomic, copy) NSString *title;

@end

@interface ZDemoCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *label;

@end
