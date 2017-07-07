//
//  ZDemoSortView.h
//  ZSortCollectionView
//
//  Created by ZhangBob on 07/07/2017.
//  Copyright © 2017 Jixin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZDemoSortView : UIView

@property (nonatomic, copy) void (^hideBlock)();
@property (nonatomic, copy) void (^doneBlock)();

@end
