#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"


typedef enum tagDataSourceError
{
    DataSourceErrorRequestCancelled,
    DataSourceErrorRequestFailed
}DataSourceError;


@interface LAbstractASIDataSource : NSObject
{
    NSMutableDictionary *_requestsDict;
}


- (void)getDataWithUrl:(NSString *)url
           cachePolicy:(ASICachePolicy)cachePolicy
       timeoutInterval:(NSTimeInterval)timeoutInterval
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
                           headers:(NSDictionary *)headers
                        parameters:(NSDictionary *)params
                     requestMethod:(NSString *)requestMethod
                       finishBlock:(void(^)(ASIHTTPRequest *req))finishBlock;


@end