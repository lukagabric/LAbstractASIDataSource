@protocol LParserInterface <NSObject>


@property (readonly, nonatomic) NSError *error;
@property (readonly, nonatomic) NSArray *itemsArray;


- (void)parseData:(NSData *)data;


@end