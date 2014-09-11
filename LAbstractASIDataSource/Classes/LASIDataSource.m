//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "LASIDataSource.h"
#import "MBProgressHUD.h"


@implementation LASIDataSource


#pragma mark - Init


- (instancetype)initWithRequest:(ASIHTTPRequest *)request
{
	self = [super init];
	if (self)
	{
        _request = request;
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


- (void)fetchDataWithCompletionBlock:(DataCompletionBlock)completionBlock
{
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    
    if (_running || _finished) return;
    
    self.dataCompletionBlock = completionBlock;
    
    [self loadDidStart];
    
	if (!_request || !_request.url)
	{
        if (!_cancelled)
        {
            [self hideProgressForActivityView];
            [self loadDidFinishWithError:[NSError errorWithDomain:@"Incorrect request parameters, is url nil?" code:400 userInfo:nil] cancelled:NO];
        }
	}
	else
	{
        if (_activityView)
            [self showProgressForActivityView];
        
        __weak typeof(self) weakSelf = self;
		__weak ASIHTTPRequest *req = _request;
        
        void (^reqCompletionBlock)(ASIHTTPRequest *asiHttpRequest) = ^(ASIHTTPRequest *asiHttpRequest) {
            if ([weakSelf isResponseValid])
            {
                if (weakSelf.activityView)
                    [weakSelf showProgressForActivityView];
            
                if (!weakSelf.cancelled)
                    [weakSelf loadDidFinishWithError:asiHttpRequest.error cancelled:NO];
            }
		};
        
		[_request setCompletionBlock:^{
            reqCompletionBlock(req);
        }];
        
		[_request setFailedBlock:^{
            reqCompletionBlock(req);
        }];
                
        [_request startAsynchronous];
	}
}


#pragma mark - Get and parse data


- (void)fetchObjectsWithCompletionBlock:(ObjectsCompletionBlock)completionBlock
{
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    
    if (_running || _finished) return;
    
    self.objectsCompletionBlock = completionBlock;

    [self loadDidStart];
    
	if (!_request || !_request.url)
	{
        if (!_cancelled)
        {
            [self hideProgressForActivityView];
            [self loadDidFinishWithError:[NSError errorWithDomain:@"Incorrect request parameters, is url nil?" code:400 userInfo:nil] cancelled:NO];
        }
	}
	else
	{
        if (_activityView)
            [self showProgressForActivityView];
        
        __weak typeof(self) weakSelf = self;
		__weak ASIHTTPRequest *weakReq = _request;
        
		[_request setCompletionBlock:^{
            if ([weakSelf isResponseValid] && weakSelf.objectsCompletionBlock && !weakSelf.cancelled)
                [weakSelf parseData];
        }];
        
		[_request setFailedBlock:^{
            if (!weakSelf.cancelled)
            {
                [weakSelf hideProgressForActivityView];
                [weakSelf loadDidFinishWithError:weakReq.error cancelled:NO];
            }
        }];
        
        [_request startAsynchronous];
	}
}


#pragma mark - Parse data


- (void)parseData
{
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ASIHTTPRequest *req = weakSelf.request;
        Class parserClass = [req.userInfo objectForKey:@"parserClass"];
        
        NSAssert(parserClass, @"Parser class must be set with the request");
        
        NSError *parserError;
        
        if (!weakSelf.cancelled)
        {
            id <LParserInterface> parser = [[parserClass class] new];
            weakSelf.parser = parser;
            [parser setUserInfo:[req.userInfo objectForKey:@"parserUserInfo"]];
            [parser setASIHTTPRequest:req];
            [parser parseData:req.responseData];
            
            parserError = [parser getError];
            
            if (!parserError)
                weakSelf.parsedItems = [parser getItemsArray];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideProgressForActivityView];
            
            if (!weakSelf.cancelled)
            {
                [weakSelf loadDidFinishWithError:parserError cancelled:NO];
            }
            else
            {
                NSLog(@"Load cancelled.");
            }
        });
    });
}


#pragma mark - Is response valid


- (BOOL)isResponseValid
{
    return YES;
}


#pragma mark - Status


- (void)loadDidFinishWithError:(NSError *)error cancelled:(BOOL)cancelled
{
    _finished = YES;
    _running = NO;
    _cancelled = cancelled;
    _error = error;
    
    if (self.dataCompletionBlock)
        self.dataCompletionBlock(_request, error);
    else if (self.objectsCompletionBlock)
        self.objectsCompletionBlock(_request, _parsedItems, error);
}


- (void)loadDidStart
{
    _finished = NO;
    _running = YES;
    _cancelled = NO;
    _error = nil;
}


#pragma mark - Cancel Load


- (void)cancelLoad
{
    if (![[NSThread currentThread] isMainThread])
    {
        [self performSelectorOnMainThread:@selector(cancelLoad) withObject:nil waitUntilDone:NO];
        return;
    }
    
    if (_finished || _cancelled) return;
    
    [_request clearDelegatesAndCancel];
    [_parser abortParsing];
    
    [self loadDidFinishWithError:nil cancelled:YES];
}


#pragma mark - Progress


- (void)showProgressForActivityView
{
    NSArray *huds = [MBProgressHUD allHUDsForView:_activityView];
    
    if (huds && [huds count] == 0)
    {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:_activityView];
        hud.dimBackground = YES;
        [_activityView addSubview:hud];
        [hud show:YES];
    }
}


- (void)hideProgressForActivityView
{
    if (_activityView)
        [MBProgressHUD hideAllHUDsForView:_activityView animated:YES];
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
    
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    
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