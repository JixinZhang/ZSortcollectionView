//
//  ZChannelModel.m
//  GoldBaseFramework
//
//  Created by ZhangBob on 07/07/2017.
//  Copyright © 2017 Jixin. All rights reserved.
//

#import "ZChannelModel.h"

@interface ZChannelModel()

@property(nonatomic, copy) NSString* channelId;
@property(nonatomic, copy) NSString* channelKey;
@property(nonatomic, copy) NSString* displayName;
@property(nonatomic, copy) NSString* url;
@property(nonatomic) BOOL sticky;

@end

@implementation ZChannelModel

- (id) initWithContent:(id)content {
    self = [super init];
    if (self){
        self.channelId = [NSString stringWithFormat:@"%@", [self dictionary:content stringValueForKey:@"id"]];
        self.channelKey = [self dictionary:content stringValueForKey:@"key"];
        self.displayName = [self dictionary:content stringValueForKey:@"display_name"];
        self.url = [self dictionary:content stringValueForKey:@"uri"];
        self.sticky = [self dictionary:content boolValueForKey:@"is_sticky"];
        self.picked = [self dictionary:content boolValueForKey:@"is_selected"];
    }
    return self;
}

- (BOOL) isEqual:(ZChannelModel *)object{
    return [self.channelKey isEqualToString:object.channelKey];
}

- (void) update:(ZChannelModel *)item{
    if ([self.channelKey isEqualToString:item.channelKey]){
        self.channelId = item.channelId;
        self.displayName = item.displayName;
        self.url = item.url;
        self.sticky = item.sticky;
        self.picked = item.picked;
    }
}

- (NSString *) dictionary:(NSDictionary *) content stringValueForKey:(NSString *) key {
    NSString * stringValue = [content objectForKey:key];
    return (stringValue != (NSString *)[NSNull null]) ? stringValue : @"";
}

- (BOOL) dictionary:(NSDictionary *) content boolValueForKey:(NSString *) key {
    NSNumber *num = [content objectForKey:key];
    return (num != (NSNumber *)[NSNull null]) ? [num boolValue] : NO;
}

@end

@implementation ZChannels

- (instancetype) init {
    self = [super init];
    if (self) {
        self.pickedChannels = [NSArray array];
        self.unpickedChannels = [NSArray array];
    }
    return self;
}

@end
