#import "NewsDataSource.h"
#import "NewsParser.h"


@implementation NewsDataSource


- (NSString *)newsItemsUrl
{
    return @"http://feeds.bbci.co.uk/news/rss.xml";
}


- (void)getNewsItemsWithCompletionBlock:(void(^)(NSArray *items, NSError *error))completionBlock
{
    [self getObjectsWithUrl:[self newsItemsUrl]
                cachePolicy:ASIAskServerIfModifiedWhenStaleCachePolicy
            timeoutInterval:20
             secondsToCache:10
                    headers:nil
                 parameters:nil
              requestMethod:@"GET"
                parserClass:[NewsParser class]
            completionBlock:^(NSArray *items, NSError *error, ASIHTTPRequest *asiHttpRequest) {
                completionBlock(items, error);
            }];
}


- (void)cancelNewsItemsRequest
{
    [self cancelRequestWithUrl:[self newsItemsUrl]];
}


@end