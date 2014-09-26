//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "DataSourceFactory.h"
#import "NewsParser.h"
#import "NewsJSONParser.h"


#define JSON 1


@implementation DataSourceFactory


+ (NSURLSession *)session
{
    return [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
}


+ (LDataSource *)newsJSONDataSource
{
    return [[LDataSource alloc] initWithSession:[self session]
                                            url:@"http://scripting.com/rss.json"
                                      andParser:[NewsJSONParser new]];
}


+ (LDataSource *)newsXMLDataSource
{
    return [[LDataSource alloc] initWithSession:[self session]
                                            url:@"http://feeds.bbci.co.uk/news/rss.xml"
                                      andParser:[NewsParser new]];
}


+ (LDataSource *)newsDataSourceWithActivityView:(UIView *)activityView
{
    LDataSource *newsDataSource;
#if JSON
    newsDataSource = [self newsJSONDataSource];
#else
    newsDataSource = [self newsXMLDataSource];
#endif
    newsDataSource.activityView = activityView;

    return newsDataSource;
}


@end
