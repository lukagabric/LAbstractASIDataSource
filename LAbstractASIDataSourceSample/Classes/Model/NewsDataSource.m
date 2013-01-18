#import "NewsDataSource.h"
#import "NewsParser.h"


@implementation NewsDataSource


- (NSString *)newsItemsUrl
{
    return @"http://feeds.bbci.co.uk/news/rss.xml";
}


- (void)getNewsItemsWithCompletitionBlock:(void(^)(NSArray *items, NSError *error))completitionBlock
{
    [self getDataWithUrl:[self newsItemsUrl]
             cachePolicy:ASIAskServerIfModifiedWhenStaleCachePolicy
            timeInterval:0
                 headers:nil
              parameters:nil
           requestMethod:@"GET"
             parserClass:[NewsParser class]
       completitionBlock:^(NSArray *items, NSError *error) {
           completitionBlock(items, error);
       }];
}


- (void)cancelNewsItemsRequest
{
    [self cancelRequestWithUrl:[self newsItemsUrl]];
}


@end