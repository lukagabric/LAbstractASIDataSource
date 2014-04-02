//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "NewsDataSource.h"


@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    __weak UITableView *_tableView;

    NewsDataSource *_newsDataSource;
    NSArray *_newsItems;    
}


@end