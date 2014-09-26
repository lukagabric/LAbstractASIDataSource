@protocol LParserInterface <NSObject>


- (void)parseData:(id)data;
- (void)setResponse:(NSURLResponse *)response;
- (NSError *)error;
- (NSArray *)itemsArray;
- (void)abortParsing;


@end