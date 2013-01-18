#import <UIKit/UIKit.h>
#import "NewsDataSource.h"


@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    __weak UITableView *_tableView;
    __weak UIActivityIndicatorView *_spinner;

    NewsDataSource *_newsDataSource;
    NSArray *_newsItems;    
}


@end