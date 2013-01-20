#import "NewsDataSource.h"
#import "NewsParser.h"


@implementation NewsDataSource


- (NSString *)newsItemsUrl
{
    return @"http://feeds.bbci.co.uk/news/rss.xml";
}


- (void)getNewsItemsWithCompletitionBlock:(void(^)(NSArray *items, NSError *error, NSDictionary *userInfo))completitionBlock
{
    [self getDataWithUrl:[self newsItemsUrl]
             cachePolicy:ASIDoNotReadFromCacheCachePolicy
         timeoutInterval:20
                 headers:nil
              parameters:nil
           requestMethod:@"GET"
             parserClass:[NewsParser class]
       completitionBlock:^(NSArray *items, NSError *error, NSDictionary *dictionary) {
           completitionBlock(items, error, dictionary);
       }];
}


- (void)cancelNewsItemsRequest
{
    [self cancelRequestWithUrl:[self newsItemsUrl]];
}


@end