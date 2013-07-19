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
	NSMutableDictionary *_parsersDict;
}


#pragma mark - Get data


- (void)getDataWithRequest:(ASIHTTPRequest *)request completionBlock:(void(^)(ASIHTTPRequest *asiHttpRequest, NSError *error))completionBlock;

- (void)getDataWithUrl:(NSString *)url
       completionBlock:(void(^)(ASIHTTPRequest *asiHttpRequest, NSError *error))completionBlock;

- (void)getDataWithUrl:(NSString *)url
		secondsToCache:(NSTimeInterval)secondsToCache
		timeOutSeconds:(NSTimeInterval)timeOutSeconds
		   cachePolicy:(ASICachePolicy)cachePolicy
       completionBlock:(void(^)(ASIHTTPRequest *asiHttpRequest, NSError *error))completionBlock;

- (void)getDataWithUrl:(NSString *)url
		secondsToCache:(NSTimeInterval)secondsToCache
		timeOutSeconds:(NSTimeInterval)timeOutSeconds
		   cachePolicy:(ASICachePolicy)cachePolicy
			   headers:(NSDictionary *)headers
			parameters:(NSDictionary *)params
		 requestMethod:(NSString *)requestMethod
       completionBlock:(void(^)(ASIHTTPRequest *asiHttpRequest, NSError *error))completionBlock;


#pragma mark - Get and parse data


- (void)getObjectsWithRequest:(ASIHTTPRequest *)request
				  parserClass:(Class)parserClass
              completionBlock:(void(^)(NSArray *items, NSError *error, ASIHTTPRequest *asiHttpRequest))completionBlock;

- (void)getObjectsFromUrl:(NSString *)url
			  parserClass:(Class)parserClass
          completionBlock:(void(^)(NSArray *items, NSError *error, ASIHTTPRequest *asiHttpRequest))completionBlock;

- (void)getObjectsWithUrl:(NSString *)url
			  cachePolicy:(ASICachePolicy)cachePolicy
		  timeoutInterval:(NSTimeInterval)timeoutInterval
		   secondsToCache:(NSTimeInterval)secondsToCache
				  headers:(NSDictionary *)headers
			   parameters:(NSDictionary *)params
			requestMethod:(NSString *)requestMethod
			  parserClass:(Class)parserClass
          completionBlock:(void(^)(NSArray *items, NSError *error, ASIHTTPRequest *asiHttpRequest))completionBlock;


#pragma mark - Cancel


- (BOOL)isRunningRequestForUrl:(NSString *)url;
- (void)cancelRequestWithUrl:(NSString *)url;
- (void)cancelRequest:(ASIHTTPRequest *)request;
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