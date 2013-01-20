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


#pragma mark - Create requests


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
                      timeInterval:(NSTimeInterval)timeInterval
                           headers:(NSDictionary *)headers
                        parameters:(NSDictionary *)params
                     requestMethod:(NSString *)requestMethod
                       finishBlock:(void(^)(ASIHTTPRequest *req))finishBlock
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
    request.secondsToCache = timeInterval;
    request.requestMethod = requestMethod;
    
    for (NSString *key in [headers allKeys])
        [request addRequestHeader:key value:[headers valueForKey:key]];
    
    if ([requestMethod isEqualToString:@"POST"] && paramsString)
    {
        [request setPostBody:[NSMutableData dataWithData:[paramsString dataUsingEncoding:NSUTF8StringEncoding]]];
        [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    }
    
    [request setCompletionBlock:^{
        finishBlock(request);
    }];
    
    [request setFailedBlock:^{
        finishBlock(request);
    }];
    
    return request;
}


- (void)getDataWithUrl:(NSString *)url
           cachePolicy:(ASICachePolicy)cachePolicy
          timeInterval:(NSTimeInterval)timeInterval
               headers:(NSDictionary *)headers
            parameters:(NSDictionary *)params
         requestMethod:(NSString *)requestMethod
           parserClass:(Class)parserClass
     completitionBlock:(void(^)(NSArray *items, NSError *error, NSDictionary *userInfo))completitionBlock
{
    if (!url) return;
    
    [self cancelRequestWithUrl:url];
    
    ASIHTTPRequest *request = [LAbstractASIDataSource requestWithUrl:url
                                                         cachePolicy:cachePolicy
                                                        timeInterval:timeInterval
                                                             headers:headers
                                                          parameters:params
                                                       requestMethod:requestMethod
                                                         finishBlock:^(ASIHTTPRequest *req)
                               {
                                   [_requestsDict removeObjectForKey:url];
                                   
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
                               }];
    
    [_requestsDict setObject:request forKey:url];
    
    [request startAsynchronous];
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