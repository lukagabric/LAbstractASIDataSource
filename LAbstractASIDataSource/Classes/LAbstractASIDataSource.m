#import "LAbstractASIDataSource.h"
#import "MBProgressHUD+L.h"


#pragma mark - DSAssert


#if DEBUG
#define DSAssert(condition, desc, ...)	\
do {				\
__PRAGMA_PUSH_NO_EXTRA_ARG_WARNINGS \
if (!(condition)) {		\
[[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd \
object:self file:[NSString stringWithUTF8String:__FILE__] \
lineNumber:__LINE__ description:(desc), ##__VA_ARGS__]; \
}				\
__PRAGMA_POP_NO_EXTRA_ARG_WARNINGS \
} while(0)
#else
#define DSAssert(condition, desc, ...)
#endif


@implementation LAbstractASIDataSource


#pragma mark - Init


- (id)init
{
	self = [super init];
	if (self)
	{
        [self initialize];
	}
	return self;
}


- (void)initialize
{
    
}


- (void)dealloc
{
    [self cancelLoad];
}


#pragma mark - Get data


- (void)getDataWithRequest:(ASIHTTPRequest *)request
        andCompletionBlock:(void (^)(ASIHTTPRequest *asiHttpRequest, NSError *error))completionBlock
{
    DSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    
    if (_loadingDataInProgress) return;
    
    _loadingDataInProgress = YES;
    
	if (!request || !request.url)
	{
        if (completionBlock && !_loadCancelled)
            completionBlock(request, [NSError errorWithDomain:@"Incorrect request parameters, is url nil?" code:400 userInfo:nil]);
	}
	else
	{
        if (_activityView)
            [MBProgressHUD showProgressForView:_activityView];
        
        __weak typeof(self) weakSelf = self;
		__weak ASIHTTPRequest *req = request;
        
        void (^reqCompletionBlock)(ASIHTTPRequest *asiHttpRequest) = ^(ASIHTTPRequest *asiHttpRequest) {
            weakSelf.currentRequest = nil;
            
            if (weakSelf.activityView)
                [MBProgressHUD showProgressForView:weakSelf.activityView];
            
            if (completionBlock && !weakSelf.loadCancelled)
                completionBlock(asiHttpRequest, asiHttpRequest.error);
		};
        
		[request setCompletionBlock:^{
            reqCompletionBlock(req);
        }];
        
		[request setFailedBlock:^{
            reqCompletionBlock(req);
        }];
        
        _currentRequest = request;
        
        [request startAsynchronous];
	}
}


#pragma mark - Get and parse data


- (void)getObjectsWithRequest:(ASIHTTPRequest *)request
           andCompletionBlock:(void(^)(ASIHTTPRequest *asiHttpRequest, NSArray *parsedItems, NSError *error))completionBlock
{
    DSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    
    if (_loadingDataInProgress) return;
    
    _loadingDataInProgress = YES;
    
	if (!request || !request.url)
	{
        if (completionBlock && !_loadCancelled)
            completionBlock(request, nil, [NSError errorWithDomain:@"Incorrect request parameters, is url nil?" code:400 userInfo:nil]);
	}
	else
	{
        if (_activityView)
            [MBProgressHUD showProgressForView:_activityView];
        
        __weak typeof(self) weakSelf = self;
		__weak ASIHTTPRequest *weakReq = request;
        
		[request setCompletionBlock:^{
            weakSelf.currentRequest = nil;
            
            if (completionBlock && !weakSelf.loadCancelled)
                [weakSelf parseDataFromRequest:weakReq withCompletionBlock:completionBlock];
        }];
        
		[request setFailedBlock:^{
            weakSelf.currentRequest = nil;
            if (completionBlock && !weakSelf.loadCancelled)
                completionBlock(weakReq, nil, weakReq.error);
        }];
        
        _currentRequest = request;
        
        [request startAsynchronous];
	}
}


#pragma mark - Parse data


- (void)parseDataFromRequest:(ASIHTTPRequest *)req
         withCompletionBlock:(void(^)(ASIHTTPRequest *asiHttpRequest, NSArray *parsedItems, NSError *error))completionBlock
{
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        Class parserClass = [req.userInfo objectForKey:@"parserClass"];
        
        DSAssert(parserClass, @"Parser class must be set with the request");
        
        NSError *error;
        NSArray *parsedItems;
        
        if (!weakSelf.loadCancelled)
        {
            id <LParserInterface> parser = [[parserClass class] new];
            weakSelf.currentParser = parser;
            [parser setUserInfo:[req.userInfo objectForKey:@"parserUserInfo"]];
            [parser setASIHTTPRequest:req];
            [parser parseData:req.responseData];
            weakSelf.currentParser = nil;
            
            error = [parser getError];
            
            if (!error)
                parsedItems = [parser getItemsArray];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.activityView)
                [MBProgressHUD hideProgressForView:weakSelf.activityView];
            
            if (!weakSelf.loadCancelled)
            {
                if (completionBlock)
                    completionBlock(req, parsedItems, error);
            }
            else
            {
                NSLog(@"Load cancelled.");
            }
        });
    });
}


#pragma mark - Cancel Load


- (void)cancelLoad
{
    @synchronized(_currentRequest)
    {
        [_currentRequest clearDelegatesAndCancel];
    }
    
    @synchronized(_currentParser)
    {
        [_currentParser abortParsing];
    }
    
    _loadCancelled = YES;
}


#pragma mark - Create request


+ (NSString *)queryStringFromParams:(NSDictionary *)dict
{
	if ([dict count] == 0)
	{
		return nil;
	}
    
	NSMutableString *query = [NSMutableString string];
    
	for (NSString *parameter in [dict allKeys])
	{
		[query appendFormat:@"&%@=%@", [parameter stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], [[dict valueForKey:parameter] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
	}
    
	return [NSString stringWithFormat:@"%@", [query substringFromIndex:1]];
}


+ (ASIHTTPRequest *)requestWithUrl:(NSString *)url
                       cachePolicy:(ASICachePolicy)cachePolicy
                   timeoutInterval:(NSTimeInterval)timeoutInterval
                    secondsToCache:(NSTimeInterval)secondsToCache
                           headers:(NSDictionary *)headers
                        parameters:(NSDictionary *)params
                     requestMethod:(NSString *)requestMethod
                       parserClass:(Class)parserClass
                    parserUserInfo:(id)parserUserInfo
{
    return [self requestWithUrl:url
                    cachePolicy:cachePolicy
                timeoutInterval:timeoutInterval
                 secondsToCache:secondsToCache
                        headers:headers
                     parameters:params
                  requestMethod:requestMethod
                       userInfo:@{@"parserClass" : parserClass, @"parserUserInfo" : parserUserInfo}];
}


+ (ASIHTTPRequest *)requestWithUrl:(NSString *)url
                       cachePolicy:(ASICachePolicy)cachePolicy
                   timeoutInterval:(NSTimeInterval)timeoutInterval
                    secondsToCache:(NSTimeInterval)secondsToCache
                           headers:(NSDictionary *)headers
                        parameters:(NSDictionary *)params
                     requestMethod:(NSString *)requestMethod
                       parserClass:(Class)parserClass
{
    return [self requestWithUrl:url
                    cachePolicy:cachePolicy
                timeoutInterval:timeoutInterval
                 secondsToCache:secondsToCache
                        headers:headers
                     parameters:params
                  requestMethod:requestMethod
                       userInfo:@{@"parserClass" : parserClass}];
}


+ (ASIHTTPRequest *)requestWithUrl:(NSString *)url
					   cachePolicy:(ASICachePolicy)cachePolicy
				   timeoutInterval:(NSTimeInterval)timeoutInterval
					secondsToCache:(NSTimeInterval)secondsToCache
						   headers:(NSDictionary *)headers
						parameters:(NSDictionary *)params
					 requestMethod:(NSString *)requestMethod
                          userInfo:(NSDictionary *)userInfo
{
	NSString *paramsString = [self queryStringFromParams:params];
	NSString *urlString = url;
    
	if ([requestMethod isEqualToString:@"GET"] && paramsString)
	{
		urlString = [url stringByAppendingFormat:@"?%@", paramsString];
	}
    
	__weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    
	request.downloadCache = [ASIDownloadCache sharedCache];
    request.cacheStoragePolicy = ASICachePermanentlyCacheStoragePolicy;
	request.cachePolicy = cachePolicy;
	request.requestMethod = requestMethod;
	request.timeOutSeconds = timeoutInterval;
	request.secondsToCache = secondsToCache;
    request.userInfo = userInfo;
    
    if (!request.requestHeaders)
        request.requestHeaders = [NSMutableDictionary new];
    
    [request.requestHeaders addEntriesFromDictionary:headers];
    
	if ([requestMethod isEqualToString:@"POST"] && paramsString)
	{
		[request setPostBody:[NSMutableData dataWithData:[paramsString dataUsingEncoding:NSUTF8StringEncoding]]];
		[request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
	}
    
	return request;
}


#pragma mark -


@end