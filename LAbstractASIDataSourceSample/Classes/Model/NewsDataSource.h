#import "LAbstractASIDataSource.h"


@interface NewsDataSource : LAbstractASIDataSource


- (void)getNewsItemsWithCompletionBlock:(void(^)(ASIHTTPRequest *asiHttpRequest, NSArray *parsedItems, NSError *error))completionBlock;


@end