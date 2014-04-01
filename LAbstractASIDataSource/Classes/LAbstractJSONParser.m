//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "LAbstractJSONParser.h"


@implementation LAbstractJSONParser


#pragma mark - Parse data


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

        if (jsonObject)
        {
            if ([jsonObject isKindOfClass:[NSDictionary class]])
            {
                _dict = jsonObject;
                [self bindObject];
            }
            else if ([jsonObject isKindOfClass:[NSArray class]])
            {
                [self bindObjectsFromArray:jsonObject];
            }
        }
	}
	else
	{
		_error = [NSError errorWithDomain:@"No data" code:0 userInfo:nil];
	}
}


- (void)bindObjectsFromArray:(NSArray *)array
{
    for (id item in array)
    {
        if ([item isKindOfClass:[NSDictionary class]])
        {
            _dict = item;
            [self bindObject];
        }
    }
}


- (void)bindObject
{
    
}


#pragma mark - Setters


- (void)setUserInfo:(id)userInfo
{
    _userInfo = userInfo;
}


- (void)setASIHTTPRequest:(ASIHTTPRequest *)request
{
    _request = request;
}


#pragma mark - Getters


- (NSString *)getDateFormat
{
    return @"yyyy-MM-dd";
}


- (NSString *)getDateTimeFormat
{
    return @"yyyy-MM-dd hh:mm:ss Z";
}


- (NSArray *)getItemsArray
{
	return [NSArray arrayWithArray:_items];
}


- (NSError *)getError
{
    return _error;
}


#pragma mark - abort


- (void)abortParsing
{
	_error = [NSError errorWithDomain:@"Parsing aborted." code:299 userInfo:nil];
}


#pragma mark -


@end