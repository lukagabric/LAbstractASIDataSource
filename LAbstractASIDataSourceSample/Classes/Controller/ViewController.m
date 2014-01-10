#import "ViewController.h"
#import "NewsItem.h"


@implementation ViewController


#pragma mark - View


- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupView];
    [self loadTableView];

    [self reloadData];
}


- (void)setupView
{
    self.title = @"News";
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadData)];
    _newsDataSource.activityView = self.view;
}


- (void)loadTableView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    _tableView = tableView;
}


#pragma mark - loadData


- (void)reloadData
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    __weak ViewController *weakSelf = self;

    if (_newsDataSource)
        [_newsDataSource cancelLoad];

    _newsDataSource = [NewsDataSource new];

    [_newsDataSource getNewsItemsWithCompletionBlock:^(ASIHTTPRequest *asiHttpRequest, NSArray *parsedItems, NSError *error) {
        if (error)
        {
            [weakSelf didFailToGetNewsItemsWithError:error];
        }
        else
        {
            [weakSelf didGetNewItems:parsedItems];
        }
        
        weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
    }];
}


- (void)didGetNewItems:(NSArray *)items
{
    _newsItems = items;
    
    [_tableView reloadData];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}


- (void)didFailToGetNewsItemsWithError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] show];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}


#pragma mark - TableView


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_newsItems count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ident = @"cellIdent";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ident];
        cell.selectionStyle = UITableViewCellEditingStyleNone;
    }
    
    NewsItem *newsItem = [_newsItems objectAtIndex:indexPath.row];
    
    cell.textLabel.text = newsItem.title;
    cell.detailTextLabel.text = newsItem.description;
    
    return cell;
}


#pragma mark -


@end