//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "LASIDataSource.h"


@interface DataSourceFactory : NSObject


+ (LASIDataSource *)newsJSONDataSource;
+ (LASIDataSource *)newsXMLDataSource;
+ (LASIDataSource *)newsDataSourceWithActivityView:(UIView *)activityView;


@end