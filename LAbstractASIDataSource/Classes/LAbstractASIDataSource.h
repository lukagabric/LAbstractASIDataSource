//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import "LParserInterface.h"


typedef void(^DataCompletionBlock)(ASIHTTPRequest *asiHttpRequest, NSError *error);
typedef void(^ObjectsCompletionBlock)(ASIHTTPRequest *asiHttpRequest, NSArray *parsedItems, NSError *error);


@interface LAbstractASIDataSource : NSObject


@property (readonly, atomic) BOOL finished;
@property (readonly, atomic) BOOL running;
@property (readonly, atomic) BOOL canceled;
@property (readonly, atomic) NSError *error;

@property (weak, nonatomic) UIView *activityView;

@property (readonly, nonatomic) ASIHTTPRequest *request;
@property (readonly, nonatomic) NSArray *parsedItems;


#pragma mark - Get data/objects


- (void)getDataWithRequest:(ASIHTTPRequest *)request andCompletionBlock:(DataCompletionBlock)completionBlock;
- (void)getObjectsWithRequest:(ASIHTTPRequest *)request andCompletionBlock:(ObjectsCompletionBlock)completionBlock;
- (void)cancelLoad;


#pragma mark -


@end


#pragma mark - Protected


@interface LAbstractASIDataSource ()


@property (strong, nonatomic) ASIHTTPRequest *request;
@property (strong, nonatomic) id <LParserInterface> parser;
@property (strong, nonatomic) NSArray *parsedItems;
@property (copy, nonatomic) DataCompletionBlock dataCompletionBlock;
@property (copy, nonatomic) ObjectsCompletionBlock objectsCompletionBlock;


- (void)initialize;

- (void)parseData;
- (BOOL)isResponseValid;

- (void)showProgressForActivityView;
- (void)hideProgressForActivityView;


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