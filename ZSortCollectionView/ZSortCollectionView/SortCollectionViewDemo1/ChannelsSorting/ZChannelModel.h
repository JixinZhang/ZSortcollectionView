//
//  ZChannelModel.h
//  GoldBaseFramework
//
//  Created by ZhangBob on 07/07/2017.
//  Copyright © 2017 Jixin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZChannelModel : NSObject

@property(nonatomic, readonly) NSString* channelId;
@property(nonatomic, readonly) NSString* channelKey;
@property(nonatomic, readonly) NSString* displayName;
@property(nonatomic, readonly) NSString* url;
@property(nonatomic, readonly) BOOL sticky;
@property(nonatomic) BOOL picked;

- (id) initWithContent:(id)content;

- (void) update:(ZChannelModel *)item;

- (BOOL) isEqual:(ZChannelModel *)object;

@end

@interface ZChannels : NSObject

@property (nonatomic, strong) NSArray *pickedChannels;
@property (nonatomic, strong) NSArray *unpickedChannels;

@end

