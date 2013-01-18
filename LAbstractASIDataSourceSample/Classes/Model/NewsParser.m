#import "NewsParser.h"
#import "NewsItem.h"


@implementation NewsParser
{
    NewsItem *_item;
}


#pragma mark - NSXMLParserDelegate


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (string != nil)
	{
		[_mElementValue appendString:string];
	}
	else
	{
		_error = [NSError errorWithDomain:@"Parsing error! Appending nil value." code:-1 userInfo:nil];
		[parser abortParsing];
	}
}


- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    _error = parseError;
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    _mElementValue = [[NSMutableString alloc] init];
    
    if ([elementName isEqualToString:@"item"])
    {
        _item = [NewsItem new];
    }
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSString *elementValue = [[NSString stringWithString:_mElementValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([elementName isEqualToString:@"item"])
    {
        [_items addObject:_item];
    }
    else if ([elementName isEqualToString:@"title"])
    {
        _item.title = elementValue;
    }
    else if ([elementName isEqualToString:@"description"])
    {
        _item.description = elementValue;
    }
}


#pragma mark - LParserInterface


- (void)parseData:(NSData *)data
{
    NSXMLParser *parser = nil;
	
    if (data != nil)
		parser = [[NSXMLParser alloc] initWithData:data];
    else
		return;
	
	_items = [NSMutableArray new];
	
    [parser setDelegate:self];
	
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
	
    [parser parse];
}


- (NSError *)error
{
    return _error;
}


- (NSArray *)itemsArray
{
    return [NSArray arrayWithArray:_items];
}


#pragma mark -


@end