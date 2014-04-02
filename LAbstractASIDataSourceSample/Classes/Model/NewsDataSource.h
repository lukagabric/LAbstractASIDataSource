//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "LAbstractASIDataSource.h"


@interface NewsDataSource : LAbstractASIDataSource


- (void)getNewsItemsWithCompletionBlock:(void(^)(ASIHTTPRequest *asiHttpRequest, NSArray *parsedItems, NSError *error))completionBlock;


@end