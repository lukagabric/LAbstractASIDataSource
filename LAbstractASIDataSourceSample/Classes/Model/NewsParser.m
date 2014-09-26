//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "NewsParser.h"
#import "NewsItem.h"


@implementation NewsParser
{
    NewsItem *_item;
}


- (void)didStartElement
{
    ifElement(@"item")
    {
        _item = [NewsItem new];
        [_items addObject:_item];
    }
}


- (void)didEndElement
{
    ifElement(@"title") bindStr(_item.newsTitle);
    elifElement(@"description") bindStr(_item.newsDescription);
}


@end