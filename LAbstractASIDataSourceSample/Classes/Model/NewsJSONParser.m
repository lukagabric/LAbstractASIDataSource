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
    bindStrJ(item.newsTitle, @"title");
    bindStrJ(item.newsDescription, @"description");
    [_items addObject:item];
}


- (NSString *)rootKeyPath
{
    return @"rss.channel.item";
}


@end