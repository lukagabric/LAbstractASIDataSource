DEPRECATED
==========

Instead https://github.com/lukagabric/LGDataSource

LAbstractASIDataSource
======================

iOS Data Source is used to simplify the process of getting remote data. See LAbstractASIDataSourceSample which shows how to get an rss feed, parse the xml and present collected data. The data source implementation itself is in the LAbstractASIDataSource class and LParserInterface.h defines a protocol that the parser must conform to.

ASIHTTPRequest is used for data download.

The idea is to use the data source by calling a method of the structure below. The data is downloaded, parsed and then the completion block is called.

    - (ASIHTTPRequest *)newsRequest
    {
        return [NewsDataSource requestWithUrl:@"http://feeds.bbci.co.uk/news/rss.xml"
                                  cachePolicy:ASIAskServerIfModifiedCachePolicy
                              timeoutInterval:15
                               secondsToCache:20
                                      headers:nil
                                   parameters:nil
                                requestMethod:@"GET"
                                  parserClass:[NewsParser class]];
    }


    - (void)getNewsItemsWithCompletionBlock:(void(^)(ASIHTTPRequest *asiHttpRequest, NSArray *parsedItems, NSError *error))completionBlock
    {
        [self getObjectsWithRequest:[self newsRequest] andCompletionBlock:completionBlock];
    }
    
LAbstractParser
---------------

Abstract parser implements core parsing methods and allows to start binding data right away. The methods below are called on element start/end and data collected is stored in member variables. There are convenient macros used to bind data quickly, including binding strings, numbers, dates, primitives etc.

    - (void)didStartElement
    {
        ifElement(@"item")
        {
            _item = [NewsItem new];
            [_items addObject:_item];
        }
    }


    - (void)didEndElement
    {
        ifElement(@"title") bindStr(_item.title);
        elifElement(@"description") bindStr(_item.description);
    }
