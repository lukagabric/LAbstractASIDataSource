#import "LAbstractASIDataSource.h"


@interface NewsDataSource : LAbstractASIDataSource


- (void)getNewsItemsWithCompletitionBlock:(void(^)(NSArray *items, NSError *error))completitionBlock;
- (void)cancelNewsItemsRequest;


@end