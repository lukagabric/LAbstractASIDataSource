#import "ViewController.h"
#import "NewsItem.h"


@implementation ViewController


#pragma mark -


- (id)init
{
    self = [super init];
    if (self)
    {
        _newsDataSource = [NewsDataSource new];
    }
    return self;
}


#pragma mark - View


- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupView];
    [self loadTableView];
    [self loadSpinner];

    [self reloadData];
}


- (void)setupView
{
    self.title = @"News";
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadData)];
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


- (void)loadSpinner
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.hidesWhenStopped = YES;
    spinner.center = self.view.center;
    spinner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:spinner];
    
    _spinner = spinner;
}


#pragma mark - loadData


- (void)reloadData
{
    [self willGetNewItems];
    
    __weak ViewController *weakSelf = self;
    
    [_newsDataSource getNewsItemsWithCompletitionBlock:^(NSArray *items, NSError *error) {
        if (error)
        {
            [weakSelf didFailToGetNewsItemsWithError:error];
        }
        else
        {
            [self didGetNewItems:items];
        }
    }];
}


- (void)willGetNewItems
{
    _newsItems = nil;
    [_tableView reloadData];
    _tableView.hidden = YES;
    [_spinner startAnimating];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}


- (void)didGetNewItems:(NSArray *)items
{
    _newsItems = items;
    
    [_tableView reloadData];
    _tableView.hidden = NO;
    [_spinner stopAnimating];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}


- (void)didFailToGetNewsItemsWithError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] show];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [_spinner stopAnimating];
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