#import "LAbstractASIDataSource.h"


@interface NewsDataSource : LAbstractASIDataSource


- (void)getNewsItemsWithCompletionBlock:(void(^)(NSArray *items, NSError *error))completionBlock;
- (void)cancelNewsItemsRequest;


@end