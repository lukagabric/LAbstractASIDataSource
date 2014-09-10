//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "LASIDataSource.h"
#import "PromiseKit.h"


@interface LASIDataSource (PromiseKit)


- (PMKPromise *)dataFetchPromise;
- (PMKPromise *)objectsFetchPromise;


@end
