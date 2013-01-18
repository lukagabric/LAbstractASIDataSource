#import "LParserInterface.h"


@interface NewsParser : NSObject <LParserInterface, NSXMLParserDelegate>
{
    NSMutableString *_mElementValue;

    NSError *_error;
    NSMutableArray *_items;
}


@end