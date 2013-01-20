#import "LAbstractASIDataSource.h"


@interface NewsDataSource : LAbstractASIDataSource


- (void)getNewsItemsWithCompletitionBlock:(void(^)(NSArray *items, NSError *error, NSDictionary *userInfo))completitionBlock;
- (void)cancelNewsItemsRequest;


@end