//
//  ZDemoCollectionViewCell.m
//  ZSortCollectionView
//
//  Created by ZhangBob on 07/07/2017.
//  Copyright © 2017 Jixin. All rights reserved.
//

#import "ZDemoCollectionViewCell.h"

@implementation ZDemoCellModel



@end

@implementation ZDemoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self z_setup];
    }
    return self;
}

- (void) z_setup {
//    [self addCellshadow];
    [self.contentView addSubview:self.label];
}

- (void)addCellshadow {
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(-1, 0);
    self.layer.shadowOpacity = 0.4;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        _label.textColor = [UIColor blackColor];
        _label.textAlignment = NSTextAlignmentCenter;
    }
    return _label;
}

@end
