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


- (void)getDataWithRequest:(ASIHTTPRequest *)request
         completitionBlock:(void (^)(NSData *, NSError *, NSDictionary *))completitionBlock;

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

- (void)cancelRequestWithUrl:(NSString *)url;
- (void)cancelAllRequests;


+ (ASIHTTPRequest *)requestWithUrl:(NSString *)url
                       cachePolicy:(ASICachePolicy)cachePolicy
                   timeoutInterval:(NSTimeInterval)timeoutInterval
                    secondsToCache:(NSTimeInterval)secondsToCache
                           headers:(NSDictionary *)headers
                        parameters:(NSDictionary *)params
                     requestMethod:(NSString *)requestMethod;


@end