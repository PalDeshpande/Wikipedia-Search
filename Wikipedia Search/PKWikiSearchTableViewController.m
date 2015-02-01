//
//  PKWikiSearchTableViewController.m
//  Wikipedia Search
//
//  Created by Pallavi Keskar on 1/30/15.
//  Copyright (c) 2015 pallavi.com. All rights reserved.
//

#import "PKWikiSearchTableViewController.h"
#import "AFNetworking.h"
#import "PKWikiPageViewController.h"
#import "UIScrollView+SVInfiniteScrolling.h"


static NSString * const baseURL =@"http://en.wikipedia.org/w/api.php";

@interface PKWikiSearchTableViewController ()<UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray *searchResults;
@property (strong, nonatomic)NSString *searchTitle;

@end

@implementation PKWikiSearchTableViewController

#pragma mark - Lazy instantiation

- (NSMutableArray *)searchResults
{
    if (!_searchResults) {
        _searchResults = [[NSMutableArray alloc] init];
    }
    return _searchResults;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak PKWikiSearchTableViewController *weakSelf = self;
    
    self.navigationController.navigationBar.barTintColor = [UIColor grayColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.backBarButtonItem.tintColor = [UIColor blackColor];
    self.searchBar.delegate = self;
    
    // setup infinite scrolling
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf performSearch:weakSelf.searchTitle andOffset: (int)([weakSelf.searchResults count] + 1)];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:YES animated:YES];
    self.tableView.allowsSelection = NO;
    self.tableView.scrollEnabled = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //call a method that performs search asynchronously and sets the result array
    [self.searchResults removeAllObjects];
    self.searchTitle = self.searchBar.text;
    [self performSearch:self.searchTitle andOffset:0];
    
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
    self.tableView.allowsSelection = YES;
    self.tableView.scrollEnabled = YES;
}

#pragma mark - helper methods

- (void)performSearch:(NSString *)searchItem andOffset:(int)offset
{
    NSString *pageLimit = [NSString stringWithFormat:@"%i", 15];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary *parameters = @{
                                 @"format" : @"json",
                                 @"action" : @"query",
                                 @"sroffset":@(offset),
                                 @"srlimit":pageLimit,
                                 @"srprop" : @"timestamp",
                                 @"srsearch" : searchItem,
                                 @"list" : @"search"
                                 };
    [self fetchDataWithParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *returnedResult = (NSDictionary *)responseObject;
        
        [self parseData:returnedResult[@"query"][@"search"]];
        [self.tableView reloadData];
        [self.tableView.infiniteScrollingView stopAnimating];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error searching"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        [self.tableView.infiniteScrollingView stopAnimating];
    }];
    
    
    
}

//using wikipedia api query for the searched title.
- (void )fetchDataWithParameters:(id)parameters
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure

{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        [manager.requestSerializer setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
        AFHTTPRequestOperation *operation =[manager GET:baseURL
                                             parameters:parameters
                                                success:success failure:failure];
        [operation setCacheResponseBlock:^NSCachedURLResponse *(NSURLConnection *connection, NSCachedURLResponse *cachedResponse) {
            return cachedResponse;
        }];
    });
    
}


//convert the timestamp to NSDate.
- (NSString *)timeStampToDate:(NSString *)timeStamp
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    // Always use this locale when parsing fixed format date strings
    NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:posix];
    NSDate *date = [formatter dateFromString:timeStamp];
    return [NSDateFormatter localizedStringFromDate:date
                                          dateStyle:NSDateFormatterShortStyle
                                          timeStyle:NSDateFormatterShortStyle];
    
}

- (void)parseData:(NSArray *)fetchedData
{
    for (NSDictionary *dictionary in fetchedData) {
        [self.searchResults addObject:dictionary];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.searchResults count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *result = [[NSDictionary alloc] initWithDictionary:self.searchResults[indexPath.row]];
    cell.textLabel.text = result[@"title"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Last updated on: %@",[self timeStampToDate:result[@"timestamp"]]];
    
    return cell;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"wikiPage" sender:indexPath];
}



#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[PKWikiPageViewController class]]) {
        if ([segue.identifier isEqualToString:@"wikiPage"]) {
            PKWikiPageViewController *wikiPageVC = segue.destinationViewController;
            NSIndexPath *path = sender;
            NSDictionary *searchedItem = self.searchResults[path.row];
            wikiPageVC.searchTitle = searchedItem[@"title"];
        }
        
    }
}


@end
