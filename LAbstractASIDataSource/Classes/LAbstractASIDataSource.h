//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import "LParserInterface.h"


@interface LAbstractASIDataSource : NSObject


@property (weak, nonatomic) UIView *activityView;


#pragma mark - Get data/objects


- (void)getDataWithRequest:(ASIHTTPRequest *)request
        andCompletionBlock:(void (^)(ASIHTTPRequest *asiHttpRequest, NSError *error))completionBlock;

- (void)getObjectsWithRequest:(ASIHTTPRequest *)request
           andCompletionBlock:(void(^)(ASIHTTPRequest *asiHttpRequest, NSArray *parsedItems, NSError *error))completionBlock;

- (void)cancelLoad;


#pragma mark -


@end


#pragma mark - Protected


@interface LAbstractASIDataSource ()


@property (assign, nonatomic) BOOL loadingDataInProgress;
@property (assign, nonatomic) BOOL loadCancelled;
@property (weak, nonatomic) ASIHTTPRequest *currentRequest;
@property (weak, nonatomic) id <LParserInterface> currentParser;


- (void)initialize;

- (void)parseDataFromRequest:(ASIHTTPRequest *)req
         withCompletionBlock:(void(^)(ASIHTTPRequest *asiHttpRequest, NSArray *parsedItems, NSError *error))completionBlock;

- (void)showProgressForActivityView;
- (void)hideProgressForActivityView;

- (BOOL)shouldProcessResponseForRequest:(ASIHTTPRequest *)request;


+ (NSString *)queryStringFromParams:(NSDictionary *)dict;

+ (ASIHTTPRequest *)requestWithUrl:(NSString *)url
                       cachePolicy:(ASICachePolicy)cachePolicy
                   timeoutInterval:(NSTimeInterval)timeoutInterval
                    secondsToCache:(NSTimeInterval)secondsToCache
                           headers:(NSDictionary *)headers
                        parameters:(NSDictionary *)params
                     requestMethod:(NSString *)requestMethod
                       parserClass:(Class)parserClass;

+ (ASIHTTPRequest *)requestWithUrl:(NSString *)url
                       cachePolicy:(ASICachePolicy)cachePolicy
                   timeoutInterval:(NSTimeInterval)timeoutInterval
                    secondsToCache:(NSTimeInterval)secondsToCache
                           headers:(NSDictionary *)headers
                        parameters:(NSDictionary *)params
                     requestMethod:(NSString *)requestMethod
                       parserClass:(Class)parserClass
                    parserUserInfo:(id)parserUserInfo;

+ (ASIHTTPRequest *)requestWithUrl:(NSString *)url
                       cachePolicy:(ASICachePolicy)cachePolicy
                   timeoutInterval:(NSTimeInterval)timeoutInterval
                    secondsToCache:(NSTimeInterval)secondsToCache
                           headers:(NSDictionary *)headers
                        parameters:(NSDictionary *)params
                     requestMethod:(NSString *)requestMethod
                          userInfo:(NSDictionary *)userInfo;


@end