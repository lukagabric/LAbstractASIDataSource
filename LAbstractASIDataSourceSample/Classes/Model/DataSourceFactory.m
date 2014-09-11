//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "DataSourceFactory.h"
#import "NewsParser.h"
#import "NewsJSONParser.h"


#define JSON 1


@implementation DataSourceFactory


+ (ASIHTTPRequest *)newsJSONRequest
{
    return [LASIDataSource requestWithUrl:@"http://scripting.com/rss.json"
                              cachePolicy:ASIAskServerIfModifiedCachePolicy
                          timeoutInterval:15
                           secondsToCache:20
                                  headers:nil
                               parameters:nil
                            requestMethod:@"GET"
                              parserClass:[NewsJSONParser class]];
}


+ (ASIHTTPRequest *)newsXMLRequest
{
    return [LASIDataSource requestWithUrl:@"http://feeds.bbci.co.uk/news/rss.xml"
                              cachePolicy:ASIAskServerIfModifiedCachePolicy
                          timeoutInterval:15
                           secondsToCache:20
                                  headers:nil
                               parameters:nil
                            requestMethod:@"GET"
                              parserClass:[NewsParser class]];
}


+ (LASIDataSource *)newsJSONDataSource
{
    return [[LASIDataSource alloc] initWithRequest:[self newsJSONRequest]];
}


+ (LASIDataSource *)newsXMLDataSource
{
    return [[LASIDataSource alloc] initWithRequest:[self newsXMLRequest]];
}


+ (LASIDataSource *)newsDataSourceWithActivityView:(UIView *)activityView
{
    LASIDataSource *newsDataSource;
#if JSON
    newsDataSource = [self newsJSONDataSource];
#else
    newsDataSource = [self newsXMLDataSource];
#endif
    newsDataSource.activityView = activityView;

    return newsDataSource;
}


@end
