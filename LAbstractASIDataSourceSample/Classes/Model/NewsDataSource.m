//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "NewsDataSource.h"
#import "NewsParser.h"
#import "NewsJSONParser.h"


#define JSON 0


@implementation NewsDataSource


- (ASIHTTPRequest *)newsRequest
{
#if JSON
    return [NewsDataSource requestWithUrl:@"http://scripting.com/rss.json"
                              cachePolicy:ASIAskServerIfModifiedCachePolicy
                          timeoutInterval:15
                           secondsToCache:20
                                  headers:nil
                               parameters:nil
                            requestMethod:@"GET"
                              parserClass:[NewsJSONParser class]];
#else
    return [NewsDataSource requestWithUrl:@"http://feeds.bbci.co.uk/news/rss.xml"
                              cachePolicy:ASIAskServerIfModifiedCachePolicy
                          timeoutInterval:15
                           secondsToCache:20
                                  headers:nil
                               parameters:nil
                            requestMethod:@"GET"
                              parserClass:[NewsParser class]];
#endif
}


- (void)getNewsItemsWithCompletionBlock:(void(^)(ASIHTTPRequest *asiHttpRequest, NSArray *parsedItems, NSError *error))completionBlock
{
    [self getObjectsWithRequest:[self newsRequest] andCompletionBlock:completionBlock];
}


@end