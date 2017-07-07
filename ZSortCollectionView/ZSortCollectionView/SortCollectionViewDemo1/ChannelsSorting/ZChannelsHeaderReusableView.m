//
//  ZChannelsHeaderReusableView.m
//  MCommonUI
//
//  Created by ZhangBob on 07/07/2017.
//  Copyright © 2017 Jixin. All rights reserved.
//

#import "ZChannelsHeaderReusableView.h"

#define kUIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ZChannelsHeaderReusableView()

@property (nonatomic, strong) UILabel *zNameLabel;
@property (nonatomic, strong) UILabel *zDetailLabel;

@end

@implementation ZChannelsHeaderReusableView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.zNameLabel];
        [self addSubview:self.zDetailLabel];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (UILabel *) zNameLabel {
    if (!_zNameLabel) {
        _zNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, 140, 17)];
        _zNameLabel.textColor = kUIColorFromRGB(0x333333);
        _zNameLabel.numberOfLines = 1;
        _zNameLabel.font = [UIFont systemFontOfSize:16.0f];
        _zNameLabel.backgroundColor = [UIColor clearColor];
        _zNameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _zNameLabel;
}

- (UILabel *) zDetailLabel {
    if (!_zDetailLabel) {
        _zDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds) - 156, 20, 140, 17)];
        _zDetailLabel.textColor = kUIColorFromRGB(0x808080);
        _zDetailLabel.numberOfLines = 1;
        _zDetailLabel.font = [UIFont systemFontOfSize:12.0f];
        _zDetailLabel.backgroundColor = [UIColor clearColor];
        _zDetailLabel.textAlignment = NSTextAlignmentRight;
    }
    return _zDetailLabel;
}


- (void) z_setNameContent:(NSString *) name {
    self.zNameLabel.text = name;
}

- (void) z_setDetailContent:(NSString *) name {
    self.zDetailLabel.text = name;
}

@end
