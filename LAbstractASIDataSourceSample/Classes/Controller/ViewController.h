//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "LASIDataSource.h"


@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    __weak UITableView *_tableView;

    LASIDataSource *_newsDataSource;
    NSArray *_newsItems;    
}


@end