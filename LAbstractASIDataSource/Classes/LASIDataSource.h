//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import "LParserInterface.h"


typedef void(^DataCompletionBlock)(ASIHTTPRequest *asiHttpRequest, NSError *error);
typedef void(^ObjectsCompletionBlock)(ASIHTTPRequest *asiHttpRequest, NSArray *parsedItems, NSError *error);


@interface LASIDataSource : NSObject


@property (readonly, atomic) BOOL finished;
@property (readonly, atomic) BOOL running;
@property (readonly, atomic) BOOL canceled;
@property (readonly, atomic) NSError *error;

@property (weak, nonatomic) UIView *activityView;

@property (readonly, nonatomic) ASIHTTPRequest *request;
@property (readonly, nonatomic) NSArray *parsedItems;


- (instancetype)initWithRequest:(ASIHTTPRequest *)request;

- (void)getDataWithCompletionBlock:(DataCompletionBlock)completionBlock;
- (void)getObjectsCompletionBlock:(ObjectsCompletionBlock)completionBlock;
- (void)cancelLoad;


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

+ (NSString *)queryStringFromParams:(NSDictionary *)dict;


#pragma mark -


@end


#pragma mark - Protected


@interface LASIDataSource ()


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


@end