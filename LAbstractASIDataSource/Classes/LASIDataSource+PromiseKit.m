//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "LASIDataSource+PromiseKit.h"
#import "PromiseKit.h"


@implementation LASIDataSource (PromiseKit)


- (PMKPromise *)dataFetchPromise
{
    PMKPromise *promise = [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        [self fetchDataWithCompletionBlock:^(ASIHTTPRequest *asiHttpRequest, NSError *error) {
            if (error)
                reject(error);
            else
                fulfill(asiHttpRequest);
        }];
    }];
    
    return promise;
}


- (PMKPromise *)objectsFetchPromise
{
    PMKPromise *promise = [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        [self fetchObjectsWithCompletionBlock:^(ASIHTTPRequest *asiHttpRequest, NSArray *parsedItems, NSError *error) {
            if (error)
                reject(error);
            else
                fulfill(parsedItems);
        }];
    }];
    
    return promise;
}


@end
