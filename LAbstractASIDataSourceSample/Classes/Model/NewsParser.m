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
    ifElement(@"title") bindStr(_item.title);
    elifElement(@"description") bindStr(_item.description);
}


@end