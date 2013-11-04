#import "NewsDataSource.h"
#import "NewsParser.h"


@implementation NewsDataSource


- (ASIHTTPRequest *)newsRequest
{
    return [NewsDataSource requestWithUrl:@"http://feeds.bbci.co.uk/news/rss.xml"
                              cachePolicy:ASIAskServerIfModifiedCachePolicy
                          timeoutInterval:15
                           secondsToCache:20
                                  headers:nil
                               parameters:nil
                            requestMethod:@"GET"
                              parserClass:[NewsParser class]];
}


- (void)getNewsItemsWithCompletionBlock:(void(^)(ASIHTTPRequest *asiHttpRequest, NSArray *parsedItems, NSError *error))completionBlock
{
    [self getObjectsWithRequest:[self newsRequest] andCompletionBlock:completionBlock];
}


@end