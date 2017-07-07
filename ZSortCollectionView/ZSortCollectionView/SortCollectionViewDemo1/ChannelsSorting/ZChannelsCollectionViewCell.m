//
//  ZChannelsCollectionViewCell.m
//  MCommonUI
//
//  Created by ZhangBob on 07/07/2017.
//  Copyright © 2017 Jixin. All rights reserved.
//

#import "ZChannelsCollectionViewCell.h"
#import "ZSortCollectionView.h"

#define kUIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ZChannelsCollectionViewCell()

@property (nonatomic, strong) UILabel   *zLeftLabel;
@property (nonatomic, strong) UILabel   *zNameLabel;

@property (nonatomic, strong) UIButton  *zDeleteButton;
@property (nonatomic, strong) UIButton  *zAddButton;

@property (nonatomic, assign) BOOL zCanEditable;

@end

@implementation ZChannelsCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self z_setup];
    }
    return self;
}

- (void) z_setup {
    self.backgroundColor = kUIColorFromRGB(0xFFFFFF);
    [self addCellshadow];
    [self.contentView addSubview:self.zLeftLabel];
    [self.contentView addSubview:self.zNameLabel];
    [self.contentView addSubview:self.zDeleteButton];
    [self.contentView addSubview:self.zAddButton];
}

- (void)addCellshadow {
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(-1, 0);
    self.layer.shadowOpacity = 0.4;
}

- (UILabel *)zLeftLabel {
    if (!_zLeftLabel) {
        _zLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 13, 6, 9)];
        _zLeftLabel.font = [UIFont fontWithName:@"iconfont" size:7.0f];
        _zLeftLabel.text = @"\U0000e684";
        _zLeftLabel.textColor = [UIColor lightGrayColor];
    }
    return _zLeftLabel;
}

- (UILabel *)zNameLabel {
    if (!_zNameLabel) {
        _zNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 7.5, 43, 20)];
        _zNameLabel.font = [UIFont systemFontOfSize:14.0f];
        _zNameLabel.textColor = kUIColorFromRGB(0x333333);
        _zNameLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _zNameLabel;
}

- (UIButton *)zDeleteButton {
    if (!_zDeleteButton) {
        _zDeleteButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
        _zDeleteButton.frame = CGRectMake(58, 0, 22, 35);
        _zDeleteButton.hidden = YES;
        _zDeleteButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
        [_zDeleteButton setTitleColor:kUIColorFromRGB(0xE6E6E6) forState:UIControlStateNormal];
        [_zDeleteButton setTitleColor:kUIColorFromRGB(0xE62E2E) forState:UIControlStateHighlighted];
        [_zDeleteButton addTarget:self
                          action:@selector(zDeleteButtonAction:)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _zDeleteButton;
}

- (UIButton *)zAddButton {
    if (!_zAddButton) {
        _zAddButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        _zAddButton.frame = CGRectMake(58, 0, 22, 35);
        _zAddButton.hidden = NO;
        _zAddButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
        [_zAddButton setTitleColor:kUIColorFromRGB(0x1428F0) forState:UIControlStateNormal];
        [_zAddButton addTarget:self
                       action:@selector(zAddButtonAction:)
             forControlEvents:UIControlEventTouchUpInside];
    }
    return _zAddButton;
}

#pragma mark -- Action

- (IBAction)zDeleteButtonAction:(id)sender {
    !self.deleteBlock?:self.deleteBlock(self);
    ZSortCollectionView *sortView = (ZSortCollectionView *)[self superview];
    NSIndexPath *indexPath = [sortView indexPathForCell:self];
    [sortView deleteCellWithIndexPath:indexPath];
    [self z_canEditable:NO];
}

- (IBAction)zAddButtonAction:(id)sender {
    !self.addBlock?:self.addBlock(self);
    ZSortCollectionView *sortView = (ZSortCollectionView *)[self superview];
    NSIndexPath *indexPath = [sortView indexPathForCell:self];
    [sortView addCellWithIndexPath:indexPath];
    [self z_canEditable:YES];
}

- (void) z_canEditable:(BOOL) editable {
    
    self.zCanEditable = editable;
    if (editable) {
        self.zNameLabel.textColor = kUIColorFromRGB(0x333333);
        self.backgroundColor = kUIColorFromRGB(0xFFFFFF);
        self.zDeleteButton.hidden = NO;
        self.zAddButton.hidden = YES;
        self.zLeftLabel.hidden = NO;
    }
    else {
        self.zNameLabel.textColor = kUIColorFromRGB(0x333333);
        self.zAddButton.hidden = NO;
        self.zDeleteButton.hidden = YES;
        self.zLeftLabel.hidden = YES;
    }
    
    if (_isMain) {
        self.backgroundColor = kUIColorFromRGB(0xF0F0F0);
        self.layer.shadowColor = [UIColor clearColor].CGColor;
        
        self.zAddButton.hidden = YES;
        self.zDeleteButton.hidden = YES;
        self.zLeftLabel.hidden = YES;
        
        self.zNameLabel.frame = self.bounds;
        self.zNameLabel.textColor = kUIColorFromRGB(0xAAAAAA);
        self.zNameLabel.textAlignment = NSTextAlignmentCenter;
    } else {
        self.zNameLabel.textAlignment = NSTextAlignmentLeft;
        self.zNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 7.5, 43, 20)];
        [self addCellshadow];
    }
}

- (void) setIsSorting:(BOOL)isSorting {
    _isSorting = isSorting;
    if (isSorting){
        self.zLeftLabel.textColor = kUIColorFromRGB(0x1428F0);
    }else{
        self.zLeftLabel.textColor = [UIColor lightGrayColor];
    }
}

- (void) setIsSortSelected:(BOOL)isSortSelected {
    _isSortSelected = isSortSelected;
}

#pragma mark protocol

- (void) z_doSetContentData:(id) content {
    self.zNameLabel.text = content;
}

@end
