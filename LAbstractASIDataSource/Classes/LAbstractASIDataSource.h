#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"


typedef enum tagDataSourceError
{
    DataSourceErrorIncorrectRequestParameters,
    DataSourceErrorRequestCancelled,
    DataSourceErrorRequestFailed,
}DataSourceError;


@interface LAbstractASIDataSource : NSObject
{
    NSMutableDictionary *_requestsDict;
}


#pragma mark - Get data


- (void)getDataWithRequest:(ASIHTTPRequest *)request completitionBlock:(void (^)(ASIHTTPRequest *asiHttpRequest, NSError *error))completitionBlock;

- (void)getDataWithUrl:(NSString *)url
     completitionBlock:(void (^)(ASIHTTPRequest *asiHttpRequest, NSError *error))completitionBlock;

- (void)getDataWithUrl:(NSString *)url
        secondsToCache:(NSTimeInterval)secondsToCache
        timeOutSeconds:(NSTimeInterval)timeOutSeconds
           cachePolicy:(ASICachePolicy)cachePolicy
     completitionBlock:(void (^)(ASIHTTPRequest *asiHttpRequest, NSError *error))completitionBlock;


#pragma mark - Get and parse data


- (void)getDataWithRequest:(ASIHTTPRequest *)request
               parserClass:(Class)parserClass
         completitionBlock:(void(^)(NSArray *items, NSError *error, NSDictionary *userInfo))completitionBlock;

- (void)getDataFromUrl:(NSString *)url
           parserClass:(Class)parserClass
     completitionBlock:(void(^)(NSArray *items, NSError *error, NSDictionary *userInfo))completitionBlock;

- (void)getDataWithUrl:(NSString *)url
           cachePolicy:(ASICachePolicy)cachePolicy
       timeoutInterval:(NSTimeInterval)timeoutInterval
        secondsToCache:(NSTimeInterval)secondsToCache
               headers:(NSDictionary *)headers
            parameters:(NSDictionary *)params
         requestMethod:(NSString *)requestMethod
           parserClass:(Class)parserClass
     completitionBlock:(void(^)(NSArray *items, NSError *error, NSDictionary *userInfo))completitionBlock;


#pragma mark - Cancel


- (BOOL)isRunningRequestForUrl:(NSString *)url;
- (void)cancelRequestWithUrl:(NSString *)url;
- (void)cancelAllRequests;


#pragma mark - Create request


+ (ASIHTTPRequest *)requestWithUrl:(NSString *)url
                       cachePolicy:(ASICachePolicy)cachePolicy
                   timeoutInterval:(NSTimeInterval)timeoutInterval
                    secondsToCache:(NSTimeInterval)secondsToCache
                           headers:(NSDictionary *)headers
                        parameters:(NSDictionary *)params
                     requestMethod:(NSString *)requestMethod;


#pragma mark -


@end