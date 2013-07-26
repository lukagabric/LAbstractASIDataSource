#import "LAbstractASIDataSource.h"
#import "LParserInterface.h"


@implementation LAbstractASIDataSource


#pragma mark - Init


- (id)init
{
	self = [super init];
	if (self)
	{
		_requestsDict = [NSMutableDictionary new];
		_parsersDict = [NSMutableDictionary new];
	}
	return self;
}


#pragma mark - Get data


- (void)getDataWithRequest:(ASIHTTPRequest *)request completionBlock:(void (^)(ASIHTTPRequest *asiHttpRequest, NSError *error))completionBlock
{
	if (!request || !request.url)
	{
		completionBlock(nil, [NSError errorWithDomain:@"Request is null. Incorrect request parameters?" code:DataSourceErrorIncorrectRequestParameters userInfo:nil]);
	}
	else
	{
		[self cancelRequestWithUrl:[request.url absoluteString]];
        
		__weak ASIHTTPRequest *req = request;
		__weak NSMutableDictionary *weakDict = _requestsDict;
        
		void (^ reqCompletionBlock)(ASIHTTPRequest *asiHttpRequest) = ^(ASIHTTPRequest *asiHttpRequest) {
			[weakDict removeObjectForKey:[req.url absoluteString]];
			completionBlock(asiHttpRequest, asiHttpRequest.error);
		};
        
		[request setCompletionBlock:^{
            reqCompletionBlock(req);
        }];
        
		[request setFailedBlock:^{
            reqCompletionBlock(req);
        }];
        
		[_requestsDict setObject:request forKey:[request.url absoluteString]];
        
        [request startAsynchronous];
	}
}


- (void)getDataWithUrl:(NSString *)url
       completionBlock:(void (^)(ASIHTTPRequest *asiHttpRequest, NSError *error))completionBlock
{
	__weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url] usingCache:[ASIDownloadCache sharedCache] andCachePolicy:ASIAskServerIfModifiedWhenStaleCachePolicy];
    
	request.cacheStoragePolicy = ASICachePermanentlyCacheStoragePolicy;
    
	[self getDataWithRequest:request completionBlock:completionBlock];
}


- (void)getDataWithUrl:(NSString *)url
		secondsToCache:(NSTimeInterval)secondsToCache
		timeOutSeconds:(NSTimeInterval)timeOutSeconds
		   cachePolicy:(ASICachePolicy)cachePolicy
       completionBlock:(void (^)(ASIHTTPRequest *asiHttpRequest, NSError *error))completionBlock
{
	__weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url] usingCache:[ASIDownloadCache sharedCache] andCachePolicy:cachePolicy];
    
	request.secondsToCache = secondsToCache;
	request.timeOutSeconds = timeOutSeconds;
	request.cacheStoragePolicy = ASICachePermanentlyCacheStoragePolicy;
    
	[self getDataWithRequest:request completionBlock:completionBlock];
}


- (void)getDataWithUrl:(NSString *)url
		secondsToCache:(NSTimeInterval)secondsToCache
		timeOutSeconds:(NSTimeInterval)timeOutSeconds
		   cachePolicy:(ASICachePolicy)cachePolicy
			   headers:(NSDictionary *)headers
			parameters:(NSDictionary *)params
		 requestMethod:(NSString *)requestMethod
       completionBlock:(void (^)(ASIHTTPRequest *asiHttpRequest, NSError *error))completionBlock
{
	if (!url)
	{
		completionBlock(nil, [NSError errorWithDomain:@"No url." code:-1 userInfo:nil]);
		return;
	}
    
	ASIHTTPRequest *request = [LAbstractASIDataSource requestWithUrl:url
														 cachePolicy:cachePolicy
													 timeoutInterval:timeOutSeconds
													  secondsToCache:secondsToCache
															 headers:headers
														  parameters:params
													   requestMethod:requestMethod];
    
	if (!request)
	{
		completionBlock(nil, [NSError errorWithDomain:@"Request error." code:-1 userInfo:nil]);
		return;
	}
    
	[self getDataWithRequest:request completionBlock:completionBlock];
}


#pragma mark - Get and parse data


- (void)getObjectsWithRequest:(ASIHTTPRequest *)request
				  parserClass:(Class)parserClass
              completionBlock:(void(^)(NSArray *items, NSError *error, ASIHTTPRequest *asiHttpRequest))completionBlock
{
	if (!request)
	{
		completionBlock(nil, [NSError errorWithDomain:@"Request is null. Incorrect request parameters?" code:DataSourceErrorIncorrectRequestParameters userInfo:nil], request);
	}
	else
	{
		[self cancelRequestWithUrl:[request.url absoluteString]];
        
		__weak LAbstractASIDataSource *weakSelf = self;
		__weak ASIHTTPRequest *req = request;
		__weak NSMutableDictionary *weakDict = _requestsDict;
        
		void (^ reqCompletionBlock)(ASIHTTPRequest *asiHttpRequest) = ^(ASIHTTPRequest *asiHttpRequest) {
			[weakDict removeObjectForKey:[asiHttpRequest.url absoluteString]];
			[weakSelf parseDataFromRequest:asiHttpRequest parserClass:parserClass completionBlock:completionBlock];
		};
        
		[request setCompletionBlock:^{
            reqCompletionBlock(req);
        }];
        
		[request setFailedBlock:^{
            reqCompletionBlock(req);
        }];
        
		[_requestsDict setObject:request forKey:[request.url absoluteString]];
        
        [request startAsynchronous];
	}
}


- (void)getObjectsFromUrl:(NSString *)url
			  parserClass:(Class)parserClass
          completionBlock:(void(^)(NSArray *items, NSError *error, ASIHTTPRequest *asiHttpRequest))completionBlock
{
	[self getObjectsWithRequest:[ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]] parserClass:parserClass completionBlock:completionBlock];
}


- (void)getObjectsWithUrl:(NSString *)url
			  cachePolicy:(ASICachePolicy)cachePolicy
		  timeoutInterval:(NSTimeInterval)timeoutInterval
		   secondsToCache:(NSTimeInterval)secondsToCache
				  headers:(NSDictionary *)headers
			   parameters:(NSDictionary *)params
			requestMethod:(NSString *)requestMethod
			  parserClass:(Class)parserClass
          completionBlock:(void(^)(NSArray *items, NSError *error, ASIHTTPRequest *asiHttpRequest))completionBlock
{
	ASIHTTPRequest *request = [LAbstractASIDataSource requestWithUrl:url
														 cachePolicy:cachePolicy
													 timeoutInterval:timeoutInterval
													  secondsToCache:secondsToCache
															 headers:headers
														  parameters:params
													   requestMethod:requestMethod];
    
	[self getObjectsWithRequest:request parserClass:parserClass completionBlock:completionBlock];
}


#pragma mark - Parse data


- (void)parseDataFromRequest:(ASIHTTPRequest *)req
				 parserClass:(Class)parserClass
             completionBlock:(void(^)(NSArray *items, NSError *error, ASIHTTPRequest *asiHttpRequest))completionBlock
{
	if (req.error)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
            if ([req isCancelled])
            {
                completionBlock(nil, [NSError errorWithDomain:@"Data request cancelled" code:DataSourceErrorRequestCancelled userInfo:nil], req);
            }
            else
            {
                completionBlock(nil, [NSError errorWithDomain:@"Data request failed" code:DataSourceErrorRequestFailed userInfo:nil], req);
            }
        });
	}
	else
	{
        __weak NSMutableDictionary *weakParsersDict = _parsersDict;

		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            id <LParserInterface> parser = [[parserClass class] new];
            [weakParsersDict setObject:parser forKey:[req.url absoluteString]];
            [parser parseData:req.responseData];
            [weakParsersDict removeObjectForKey:[req.url absoluteString]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([parser error])
                {
                    completionBlock(nil, parser.error, req);
                }
                else
                {
                    completionBlock(parser.itemsArray, nil, req);
                }
            });
        });
	}
}


#pragma mark - Running request


- (BOOL)isRunningRequestForUrl:(NSString *)url
{
	ASIHTTPRequest *req = [_requestsDict objectForKey:url];
    
	return req != nil;
}


#pragma mark - Cancel requests


- (void)cancelRequestWithUrl:(NSString *)url
{
	if (!url)
	{
		return;
	}
    
	ASIHTTPRequest *req = [_requestsDict objectForKey:url];
    
	if (req)
	{
		[req clearDelegatesAndCancel];
		[_requestsDict removeObjectForKey:url];
	}
    
	id <LParserInterface> parser = [_parsersDict objectForKey:url];
    
	if (parser)
	{
		[parser abortParsing];
		[_parsersDict removeObjectForKey:url];
	}
}


- (void)cancelRequest:(ASIHTTPRequest *)request
{
    [self cancelRequestWithUrl:[request.url absoluteString]];
}


- (void)cancelAllRequests
{
	for (ASIHTTPRequest *req in [_requestsDict allValues])
		[req clearDelegatesAndCancel];
    
	[_requestsDict removeAllObjects];
    
    for (id <LParserInterface> parser in [_parsersDict allValues])
        [parser abortParsing];
    
    [_parsersDict removeAllObjects];
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
    
	for (NSString *key in [headers allKeys])
	{
		[request addRequestHeader:key value:[headers valueForKey:key]];
	}
    
	if ([requestMethod isEqualToString:@"POST"] && paramsString)
	{
		[request setPostBody:[NSMutableData dataWithData:[paramsString dataUsingEncoding:NSUTF8StringEncoding]]];
		[request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
	}
    
	return request;
}


#pragma mark - dealloc


- (void)dealloc
{
	[self cancelAllRequests];
}


#pragma mark -


@end