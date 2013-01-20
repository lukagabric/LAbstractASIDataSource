LAbstractASIDataSource
======================

iOS Data Source is used to simplify the process of getting data from web. See LAbstractASIDataSourceSample which shows how to get an rss feed, parse the xml and present collected data. The data source implementation itself is in the LAbstractASIDataSource class and LParserInterface.h defines a protocol that the parser must conform to.

The idea is to use the data source by calling a method of the structure below. The data is downloaded, parsed and then the completition block is called.

    [_newsDataSource getNewsItemsWithCompletitionBlock:^(NSArray *items, NSError *error, NSDictionary *userInfo) {
        if (error)
        {
            //handle error
        }
        else
        {
            //use items
        }
    }];

Implementation sample
---------------------

Before you start with the data source you need the data parser that conforms to LParserInterface protocol.

Subclass LAbstractASIDataSource class as in NewsDataSource class of the sample project. In that class, three methods are implemented. These methods are convenient, and used to get data from e.g. UIViewController where you want to present this data.

First method just returns the data url.

    - (NSString *)newsItemsUrl
    {
        return @"http://feeds.bbci.co.uk/news/rss.xml";
    }

Second method uses method implemented in the super class LAbstractASIDataSource. There are a number of parameters to be defined. Among them is the parser class which will be used to parse the data and return the parsed entities. It must conform to LParserInterface. The completition block is passed in as a parameter and it will be executed after the request is finish and the data is parsed.

    - (void)getNewsItemsWithCompletitionBlock:(void(^)(NSArray *items, NSError *error, NSDictionary *userInfo))completitionBlock
    {
        [self getDataWithUrl:[self newsItemsUrl]
                 cachePolicy:ASIAskServerIfModifiedWhenStaleCachePolicy
             timeoutInterval:20
                     headers:nil
                  parameters:nil
               requestMethod:@"GET"
                 parserClass:[NewsParser class]
           completitionBlock:^(NSArray *items, NSError *error, NSDictionary *dictionary) {
              completitionBlock(items, error, dictionary);
        }];
    }

The third method is used to cancel the request.


    - (void)cancelNewsItemsRequest
    {
        [self cancelRequestWithUrl:[self newsItemsUrl]];
    }

Now data can be used in e.g. view controller which owns an instance of data source class. As shown in the sample project:

    [_newsDataSource getNewsItemsWithCompletitionBlock:^(NSArray *items, NSError *error, NSDictionary *userInfo) {
        if (error)
        {
            //handle error
        }
        else
        {
            //use items
        }
    }];
