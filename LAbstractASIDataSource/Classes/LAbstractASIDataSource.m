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
    }
    return self;
}


#pragma mark - Get data


- (void)getDataWithRequest:(ASIHTTPRequest *)request completitionBlock:(void (^)(NSData *, NSError *, NSDictionary *))completitionBlock
{
    if (!request)
    {
        completitionBlock(nil, [NSError errorWithDomain:@"Request is null. Incorrect request parameters?" code:DataSourceErrorIncorrectRequestParameters userInfo:nil], nil);
    }
    else
    {
        [self cancelRequestWithUrl:[request.url absoluteString]];
        
        __weak ASIHTTPRequest *req = request;
        
        void (^reqCompletitionBlock)(ASIHTTPRequest *asiHttpRequest) = ^(ASIHTTPRequest *asiHttpRequest) {
            [_requestsDict removeObjectForKey:[req.url absoluteString]];
            completitionBlock(asiHttpRequest.responseData, asiHttpRequest.error, asiHttpRequest.responseHeaders);
        };
        
        [req setCompletionBlock:^{
            reqCompletitionBlock(req);
        }];
        
        [req setFailedBlock:^{
            reqCompletitionBlock(req);
        }];
        
        [_requestsDict setObject:request forKey:[request.url absoluteString]];
        
        [request startAsynchronous];
    }
}


- (void)getDataWithRequest:(ASIHTTPRequest *)request parserClass:(Class)parserClass completitionBlock:(void(^)(NSArray *items, NSError *error, NSDictionary *userInfo))completitionBlock
{
    if (!request)
    {
        completitionBlock(nil, [NSError errorWithDomain:@"Request is null. Incorrect request parameters?" code:DataSourceErrorIncorrectRequestParameters userInfo:nil], nil);
    }
    else
    {
        [self cancelRequestWithUrl:[request.url absoluteString]];
        
        __weak LAbstractASIDataSource *weakSelf = self;
        __weak ASIHTTPRequest *req = request;
        
        void (^reqCompletitionBlock)(ASIHTTPRequest *asiHttpRequest) = ^(ASIHTTPRequest *asiHttpRequest) {
            [_requestsDict removeObjectForKey:[asiHttpRequest.url absoluteString]];
            [weakSelf parseDataFromRequest:asiHttpRequest parserClass:parserClass completitionBlock:completitionBlock];
        };
        
        [req setCompletionBlock:^{
            reqCompletitionBlock(req);
        }];
        
        [req setFailedBlock:^{
            reqCompletitionBlock(req);
        }];
        
        [_requestsDict setObject:request forKey:[request.url absoluteString]];
        
        [request startAsynchronous];
    }
}


- (void)getDataFromUrl:(NSString *)url parserClass:(Class)parserClass completitionBlock:(void(^)(NSArray *items, NSError *error, NSDictionary *userInfo))completitionBlock
{
    [self getDataWithRequest:[ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]] parserClass:parserClass completitionBlock:completitionBlock];
}


- (void)getDataWithUrl:(NSString *)url
           cachePolicy:(ASICachePolicy)cachePolicy
       timeoutInterval:(NSTimeInterval)timeoutInterval
        secondsToCache:(NSTimeInterval)secondsToCache
               headers:(NSDictionary *)headers
            parameters:(NSDictionary *)params
         requestMethod:(NSString *)requestMethod
           parserClass:(Class)parserClass
     completitionBlock:(void(^)(NSArray *items, NSError *error, NSDictionary *userInfo))completitionBlock
{
    ASIHTTPRequest *request = [LAbstractASIDataSource requestWithUrl:url
                                                         cachePolicy:cachePolicy
                                                     timeoutInterval:timeoutInterval
                                                      secondsToCache:secondsToCache
                                                             headers:headers
                                                          parameters:params
                                                       requestMethod:requestMethod];
    
    [self getDataWithRequest:request parserClass:parserClass completitionBlock:completitionBlock];
}


#pragma mark - Parse data


- (void)parseDataFromRequest:(ASIHTTPRequest *)req
                 parserClass:(Class)parserClass
           completitionBlock:(void(^)(NSArray *items, NSError *error, NSDictionary *userInfo))completitionBlock
{
    if (req.error)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([req isCancelled])
            {
                completitionBlock(nil, [NSError errorWithDomain:@"Data request cancelled" code:DataSourceErrorRequestCancelled userInfo:nil], nil);
            }
            else
            {
                completitionBlock(nil, [NSError errorWithDomain:@"Data request failed" code:DataSourceErrorRequestFailed userInfo:nil], nil);
            }
        });
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            id <LParserInterface> parser = [[parserClass class] new];
            [parser parseData:req.responseData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (parser.error)
                {
                    completitionBlock(nil, parser.error, req.responseHeaders);
                }
                else
                {
                    completitionBlock(parser.itemsArray, nil, req.responseHeaders);
                }
            });
        });
    }
}


#pragma mark - Create request


+ (NSString *)queryStringFromParams:(NSDictionary *)dict
{
    if ([dict count] == 0) return nil;
    
    NSMutableString *query = [NSMutableString string];
    
    for (NSString *parameter in [dict allKeys])
        [query appendFormat:@"&%@=%@", [parameter stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], [[dict valueForKey:parameter] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    
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
    request.cachePolicy = cachePolicy;
    request.requestMethod = requestMethod;
    request.timeOutSeconds = timeoutInterval;
    request.secondsToCache = secondsToCache;
    
    for (NSString *key in [headers allKeys])
        [request addRequestHeader:key value:[headers valueForKey:key]];
    
    if ([requestMethod isEqualToString:@"POST"] && paramsString)
    {
        [request setPostBody:[NSMutableData dataWithData:[paramsString dataUsingEncoding:NSUTF8StringEncoding]]];
        [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    }
    
    return request;
}


#pragma mark - Cancel requests


- (void)cancelRequestWithUrl:(NSString *)url
{
    if (!url) return;
    
    ASIHTTPRequest *req = [_requestsDict objectForKey:url];
    [req clearDelegatesAndCancel];
    [_requestsDict removeObjectForKey:url];
}


- (void)cancelAllRequests
{
    for (ASIHTTPRequest *req in [_requestsDict allValues])
    {
        [req clearDelegatesAndCancel];
    }
    
    [_requestsDict removeAllObjects];
}


#pragma mark - dealloc


- (void)dealloc
{
    [self cancelAllRequests];
}


#pragma mark -


@end