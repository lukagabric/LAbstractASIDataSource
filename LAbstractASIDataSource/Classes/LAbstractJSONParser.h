//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "LParserInterface.h"


#define ifIsNull(key)                ([[_currentElement objectForKey:key] isKindOfClass:[NSNull class]])
#define bindStrJ(obj, key)    obj = ifIsNull(key) ? nil : [_currentElement objectForKey:key]
#define bindIntJ(obj, key)    obj = ifIsNull(key) ? 0 : [[_currentElement objectForKey:key] intValue]
#define bindFloatJ(obj, key)  obj = ifIsNull(key) ? 0 : [[_currentElement objectForKey:key] floatValue]
#define bindNumberToStringJ(obj, key)  obj = ifIsNull(key) ? nil : [[_currentElement objectForKey:key] stringValue]
#define bindDateJ(obj, key)   obj = ifIsNull(key) ? nil : [_dateFormatter dateFromString:[_currentElement objectForKey:key]]
#define bindDateTimeJ(obj, key)   obj = ifIsNull(key) ? nil : [_dateTimeFormatter dateFromString:[_currentElement objectForKey:key]]
#define bindUrlFromDict(obj, key)	   obj = (!ifIsNull(key) && [_currentElement objectForKey:key] != nil) ? [NSURL URLWithString:key] : nil;
#define bindBoolFromDict(obj, key)   obj = ifIsNull(key) ? NO : [[_currentElement objectForKey:key] boolValue]


@interface LAbstractJSONParser : NSObject <LParserInterface>
{
	NSMutableArray *_items;
    NSError *_error;
    NSDateFormatter *_dateTimeFormatter;
    NSDateFormatter *_dateFormatter;
    
    id _rootJsonObject;
    
    NSDictionary *_currentElement;
    
    id _userInfo;
    ASIHTTPRequest *_request;
}


+ (NSArray *)objectsForData:(id)data;


@end


#pragma mark - Protected


@interface LAbstractJSONParser ()


- (void)bindObject;

- (NSString *)getDateTimeFormat;
- (NSString *)getDateFormat;
- (NSString *)getRootKeyPath;


@end