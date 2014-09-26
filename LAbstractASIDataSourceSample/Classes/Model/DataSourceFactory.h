//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "LDataSource.h"


@interface DataSourceFactory : NSObject


+ (LDataSource *)newsJSONDataSource;
+ (LDataSource *)newsXMLDataSource;
+ (LDataSource *)newsDataSourceWithActivityView:(UIView *)activityView;


@end