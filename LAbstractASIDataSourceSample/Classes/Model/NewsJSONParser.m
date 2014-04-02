//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "NewsJSONParser.h"
#import "NewsItem.h"


@implementation NewsJSONParser


- (void)bindObject
{
    NewsItem *item = [NewsItem new];
    bindStrJ(item.title, @"title");
    bindStrJ(item.description, @"description");
    [_items addObject:item];
}


- (NSString *)getRootKeyPath
{
    return @"rss.channel.item";
}


@end