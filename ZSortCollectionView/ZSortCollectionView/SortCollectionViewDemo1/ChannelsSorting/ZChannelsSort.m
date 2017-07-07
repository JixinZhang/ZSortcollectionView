//
//  ZChannelsSort.m
//  GoldBaseFramework
//
//  Created by ZhangBob on 07/07/2017.
//  Copyright © 2017 Jixin. All rights reserved.
//

#import "ZChannelsSort.h"
#import "ZChannelModel.h"
#import "ZChannelsSortView.h"

#define KScreenHeight       ([[UIScreen mainScreen] bounds].size.height)

@interface ZChannelsSort()

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) ZChannelsSortView *sortView;

@property (nonatomic, strong) ZChannels *channels;

@end

@implementation ZChannelsSort

- (void)sortChannelsAtViewController:(UIViewController *)viewController WithDictionary:(NSDictionary *)channels {
    [self handleChannelsWithDictionary:channels];
    self.window = viewController.view.window;
    [self setupSortView];
}

- (void)sortChannelsAtView:(UIView *)view WithDictionary:(NSDictionary *)channels {
    [self handleChannelsWithDictionary:channels];
    self.window = view.window;
    [self setupSortView];
}

- (void)setupSortView {
    
    self.sortView = [[ZChannelsSortView alloc] initWithFrame:CGRectMake(0, 0, [self.window bounds].size.width, KScreenHeight)];
    __weak  typeof(self) weakSelf = self;
    self.sortView.hideBlock = ^(void) {
        [weakSelf hideSortView];
    };
    
    self.sortView.doneBlock = ^(){
        [weakSelf returnSortedChannels];
    };
    
    self.sortView.channels = self.channels;
    if (self.onlyMoveInSection) {
        self.sortView.onlyMoveInSection = YES;
    }
    [self.window addSubview:self.sortView];
}

- (void)handleChannelsWithDictionary:(NSDictionary *)channels {
    if ([channels isKindOfClass:[NSDictionary class]]) {
        if (channels.count == 0) {
            return;
        }
        
        NSMutableArray *pickedChannels = [NSMutableArray array];
        NSMutableArray *unpickedChannels = [NSMutableArray array];
        
        NSArray *picked = [NSArray arrayWithArray:[channels valueForKey:@"picked"]];
        NSArray *unpicked = [NSArray arrayWithArray:[channels valueForKey:@"unpicked"]];
        for (NSDictionary *item in picked) {
            ZChannelModel *model = [[ZChannelModel alloc] initWithContent:item];
            [pickedChannels addObject:model];
        }
        
        for (NSDictionary *item in unpicked) {
            ZChannelModel *model = [[ZChannelModel alloc] initWithContent:item];
            [unpickedChannels addObject:model];
        }
        self.channels = [[ZChannels alloc] init];
        self.channels.pickedChannels = pickedChannels;
        self.channels.unpickedChannels = unpickedChannels;
    } else {
        return;
    }
}

- (void)hideSortView {
    [self.sortView removeFromSuperview];
    !self.hideSortViewBlock?:self.hideSortViewBlock();
}

- (void)returnSortedChannels {
    
    NSMutableArray *picked = [NSMutableArray array];
    NSMutableArray *unpicked = [NSMutableArray array];
    
    NSArray *pickedChannels = [NSArray array];
    NSArray *unpickedChannels = [NSArray array];
    
    pickedChannels = self.sortView.channels.pickedChannels;
    unpickedChannels = self.sortView.channels.unpickedChannels;
    
    for (ZChannelModel *model in pickedChannels) {
        NSDictionary *channel = @{@"id" : model.channelId,
                                  @"key" : model.channelKey,
                                  @"display_name": model.displayName,
                                  @"is_sticky" : @(model.sticky),
                                  @"is_selected": @(YES)
                                  };
        [picked addObject:channel];
    }
    
    for (ZChannelModel *model in unpickedChannels) {
        NSDictionary *channel = @{@"id" : model.channelId,
                                  @"key" : model.channelKey,
                                  @"display_name": model.displayName,
                                  @"is_sticky" : @(model.sticky),
                                  @"is_selected": @(NO)
                                  };
        [unpicked addObject:channel];
    }
    
    NSDictionary *dict = @{@"picked" : picked,
                           @"unpicked" : unpicked};
    if (self.channelsSortBlock) {
        self.channelsSortBlock(dict);
    }
    [self hideSortView];
}

@end
