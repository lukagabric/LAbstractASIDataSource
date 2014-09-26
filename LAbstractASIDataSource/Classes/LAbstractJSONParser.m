//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "LAbstractJSONParser.h"


@implementation LAbstractJSONParser


#pragma mark - Static methods


+ (NSArray *)objectsForData:(id)data
{
    LAbstractJSONParser *parser = [[self class] new];
    [parser parseData:data];
    return [parser itemsArray];
}


#pragma mark - init


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
    _dateTimeFormatter = [NSDateFormatter new];
    _dateTimeFormatter.dateFormat = [self dateTimeFormat];
    
    _dateFormatter = [NSDateFormatter new];
    _dateFormatter.dateFormat = [self dateFormat];
}


#pragma mark - LParserInterface


- (void)parseData:(id)data
{
	if (data)
	{
		_items = [NSMutableArray new];
        
        id jsonObject = nil;
        
        if ([data isKindOfClass:[NSData class]])
        {
            NSError *error = nil;
            
            jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            _error = error;
        }
        else
        {
            jsonObject = data;
        }

        if (jsonObject)
        {
            _rootJsonObject = jsonObject;
            
            NSString *rootKeyPath = [self rootKeyPath];
            
            if (rootKeyPath)
                _rootJsonObject = [jsonObject valueForKeyPath:rootKeyPath];
            
            if (_rootJsonObject)
            {
                if ([_rootJsonObject isKindOfClass:[NSDictionary class]])
                {
                    _currentElement = _rootJsonObject;
                    [self bindObject];
                }
                else if ([_rootJsonObject isKindOfClass:[NSArray class]])
                {
                    for (id item in _rootJsonObject)
                    {
                        if ([item isKindOfClass:[NSDictionary class]])
                        {
                            _currentElement = item;
                            [self bindObject];
                        }
                    }
                }
            }
        }
	}
	else
	{
		_error = [NSError errorWithDomain:@"No data" code:0 userInfo:nil];
	}
}


- (void)setResponse:(NSURLResponse *)response
{
    _response = response;
}


- (NSError *)error
{
    return _error;
}


- (NSArray *)itemsArray
{
    return [NSArray arrayWithArray:_items];
}


- (void)abortParsing
{
    _error = [NSError errorWithDomain:@"Parsing aborted." code:299 userInfo:nil];
}


#pragma mark - Bind object


- (void)bindObject
{

}


#pragma mark - rootKeyPath


- (NSString *)rootKeyPath
{
    return nil;
}


#pragma mark - Date/Time Format


- (NSString *)dateFormat
{
    return @"yyyy-MM-dd";
}


- (NSString *)dateTimeFormat
{
    return @"yyyy-MM-dd hh:mm:ss Z";
}


#pragma mark -


@end