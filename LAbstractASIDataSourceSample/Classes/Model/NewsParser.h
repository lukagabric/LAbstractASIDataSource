#import "LParserInterface.h"


@interface NewsParser : NSObject <LParserInterface, NSXMLParserDelegate>
{
    NSXMLParser *_parser;
    
    NSMutableString *_mElementValue;

    NSError *_error;
    NSMutableArray *_items;
}


@end