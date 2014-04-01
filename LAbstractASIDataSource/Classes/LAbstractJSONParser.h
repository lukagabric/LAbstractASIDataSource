//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "LParserInterface.h"


#define ifIsNull(key)                ([[_dict objectForKey:key] isKindOfClass:[NSNull class]])
#define bindStrJ(obj, key)    obj = ifIsNull(_dict, key) ? nil : [_dict objectForKey:key]
#define bindIntJ(obj, key)    obj = ifIsNull(_dict, key) ? 0 : [[_dict objectForKey:key] intValue]
#define bindFloatJ(obj, key)  obj = ifIsNull(_dict, key) ? 0 : [[_dict objectForKey:key] floatValue]
#define bindNumberToStringJ(obj, key)  obj = ifIsNull(_dict, key) ? nil : [[_dict objectForKey:key] stringValue]
#define bindDate(obj, key)   obj = ifIsNull(_dict, key) ? nil : [_dateFormatter dateFromString:[_dict objectForKey:key]]
#define bindDateTime(obj, key)   obj = ifIsNull(_dict, key) ? nil : [_dateTimeFormatter dateFromString:[_dict objectForKey:key]]
#define bindUrlFrom_dict(obj, key)	   obj = (!ifIsNull(_dict, key) && [_dict objectForKey:key] != nil) ? [NSURL URLWithString:key] : nil;
#define bindBoolFrom_dict(obj, key)   obj = ifIsNull(_dict, key) ? NO : [[_dict objectForKey:key] boolValue]


@interface LAbstractJSONParser : NSObject <LParserInterface>
{
	NSMutableArray *_items;
    NSError *_error;
    NSDateFormatter *_dateTimeFormatter;
    NSDateFormatter *_dateFormatter;
    
    NSDictionary *_dict;
    
    id _userInfo;
    ASIHTTPRequest *_request;
}


@end


#pragma mark - Protected


@interface LAbstractJSONParser ()


- (NSString *)getDateTimeFormat;
- (NSString *)getDateFormat;


@end