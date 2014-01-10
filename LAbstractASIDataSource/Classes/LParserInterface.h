@protocol LParserInterface <NSObject>


- (void)parseData:(NSData *)data;
- (void)setUserInfo:(id)userInfo;
- (void)setASIHTTPRequest:(ASIHTTPRequest *)request;
- (NSError *)getError;
- (NSArray *)getItemsArray;
- (void)abortParsing;


@end