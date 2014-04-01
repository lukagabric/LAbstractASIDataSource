#import "ASIHTTPRequest.h"


@protocol LParserInterface <NSObject>


- (void)parseData:(id)data;
- (void)setUserInfo:(id)userInfo;
- (void)setASIHTTPRequest:(ASIHTTPRequest *)request;
- (NSError *)getError;
- (NSArray *)getItemsArray;
- (void)abortParsing;


@end