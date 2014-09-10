//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "DataSourceFactory.h"
#import "NewsParser.h"
#import "NewsJSONParser.h"


#define JSON 0


@implementation DataSourceFactory


+ (ASIHTTPRequest *)newsRequest
{
#if JSON
    return [LASIDataSource requestWithUrl:@"http://scripting.com/rss.json"
                              cachePolicy:ASIAskServerIfModifiedCachePolicy
                          timeoutInterval:15
                           secondsToCache:20
                                  headers:nil
                               parameters:nil
                            requestMethod:@"GET"
                              parserClass:[NewsJSONParser class]];
#else
    return [LASIDataSource requestWithUrl:@"http://feeds.bbci.co.uk/news/rss.xml"
                              cachePolicy:ASIAskServerIfModifiedCachePolicy
                          timeoutInterval:15
                           secondsToCache:20
                                  headers:nil
                               parameters:nil
                            requestMethod:@"GET"
                              parserClass:[NewsParser class]];
#endif
}


+ (LASIDataSource *)newsDataSourceWithActivityView:(UIView *)activityView
{
    LASIDataSource *newsDataSource = [[LASIDataSource alloc] initWithRequest:[self newsRequest]];
    newsDataSource.activityView = activityView;
    return newsDataSource;
}


@end
