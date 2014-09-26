//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "LDataSource.h"
#import "MBProgressHUD.h"


@implementation LDataSource


#pragma mark - Init


- (instancetype)initWithSession:(NSURLSession *)session andUrl:(NSString *)url
{
	self = [super init];
	if (self)
	{
        _session = session;
        _url = [url copy];
        [self initialize];
	}
	return self;
}


- (instancetype)initWithSession:(NSURLSession *)session url:(NSString *)url andParser:(id <LParserInterface>)parser
{
    self = [super init];
    if (self)
    {
        _session = session;
        _url = [url copy];
        _parser = parser;
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


#pragma mark - Create data task


- (void)startDataTaskWithCompletionBlock:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionBlock
{
    _dataTask = [_session dataTaskWithURL:[NSURL URLWithString:_url]
                        completionHandler:completionBlock];

    [_dataTask resume];
}


#pragma mark - Get data


- (void)fetchDataWithCompletionBlock:(DataCompletionBlock)completionBlock
{
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    
    if (_running || _finished) return;
    
    self.dataCompletionBlock = completionBlock;
    
    [self loadDidStart];
    
	if (!_session || !_url)
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

        [self startDataTaskWithCompletionBlock:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (weakSelf.cancelled) return;

            weakSelf.response = response;
            weakSelf.responseData = data;

            if ([weakSelf isResponseValid])
            {
                if (weakSelf.activityView)
                    [weakSelf showProgressForActivityView];

                [weakSelf loadDidFinishWithError:error cancelled:NO];
            }
        }];
	}
}


#pragma mark - Get and parse data


- (void)fetchObjectsWithCompletionBlock:(ObjectsCompletionBlock)completionBlock
{
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    
    if (_running || _finished) return;
    
    self.objectsCompletionBlock = completionBlock;
    
    [self loadDidStart];
    
	if (!_session || !_url)
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
        
        [self startDataTaskWithCompletionBlock:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (weakSelf.cancelled) return;
            
            weakSelf.response = response;
            weakSelf.responseData = data;

            if (error)
            {
                [weakSelf hideProgressForActivityView];
                [weakSelf loadDidFinishWithError:error cancelled:NO];
            }
            else if ([weakSelf isResponseValid] && weakSelf.objectsCompletionBlock)
            {
                [weakSelf parseData];
            }
        }];
	}
}


#pragma mark - Parse data


- (void)parseData
{
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *parserError;
        
        if (!weakSelf.cancelled)
        {
            id <LParserInterface> parser = weakSelf.parser;
            [parser setResponse:weakSelf.response];
            [parser parseData:weakSelf.responseData];
            
            parserError = [parser error];
            
            if (!parserError)
                weakSelf.parsedItems = [parser itemsArray];
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
        self.dataCompletionBlock(_responseData, _response, _error);
    else if (self.objectsCompletionBlock)
        self.objectsCompletionBlock(_response, _parsedItems, _error);
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

    [_dataTask cancel];
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


#pragma mark -


@end