//
//  ZChannelsSortView.h
//  MCommonUI
//
//  Created by ZhangBob on 07/07/2017.
//  Copyright © 2017 Jixin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZChannelModel.h"

@interface ZChannelsSortView : UIView

@property(nonatomic, strong) ZChannels *channels;
/**
 设定cell只能在其所在的section中移动。默认为NO，即可以跨越section移动
 */
@property (nonatomic, assign) BOOL onlyMoveInSection;

@property (nonatomic, copy) void (^goToBlock)(id content);
@property (nonatomic, copy) void (^hideBlock)();
@property (nonatomic, copy) void (^doneBlock)();

@end
