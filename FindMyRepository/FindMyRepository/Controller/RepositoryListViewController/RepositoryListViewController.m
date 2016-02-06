//
//  RepositoryListViewController.m
//  FindMyRepository
//
//  Created by Pankaj Kumar Jha on 06/02/16.
//  Copyright © 2016 Pankaj Kumar Jha. All rights reserved.
//

#import "RepositoryListViewController.h"
#import "DataFetchManager.h"
#import "GHResults.h"
#import "GHRepository.h"
#import "Constants.h"
#import "RepositoryDetailViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface RepositoryListViewController ()
@property (strong, nonatomic) NSMutableArray *repositoryDataArray;
@property (nonatomic, assign) NSInteger pageNumber;
@property (nonatomic, assign) NSInteger totalPage;
@property (nonatomic, assign) BOOL isPageRequestValid;
@property (nonatomic, assign) NSIndexPath *selectedIndexPath;

@end

@implementation RepositoryListViewController

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cancel.text = @"Search";
    [self.cancel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showSearchResults)]];
    [self.searchBar becomeFirstResponder];
    self.repositoryDataArray   = [NSMutableArray new];
    self.searchTableView.rowHeight = UITableViewAutomaticDimension;
    self.searchTableView.estimatedRowHeight = 80;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = true;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = false;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Private Methods

- (void)backButtonTapped {
    [self.searchBar resignFirstResponder];
}

- (void)showSearchResults {
    [self.searchBar resignFirstResponder];
    if (self.searchBar.text.length>0)
    {
        [self getSearchReaults];
    }
}

- (void)getSearchReaults {
    
    @try {
        self.totalPage = 1;
        self.pageNumber = 1;
        self.isPageRequestValid = NO;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        DataFetchManager *dataFetchManager = [DataFetchManager new];
        [dataFetchManager searchRepositoryDataWithString:self.searchBar.text forPageNumber:self.pageNumber withCompletionBlock:^(GHResults *result, BOOL success, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if (success) {
                [self.repositoryDataArray removeAllObjects];
                [self.repositoryDataArray addObjectsFromArray:result.items];
                self.totalPage = result.totalCount.intValue;
                [self.searchTableView reloadData];
                [self.searchTableView setHidden:NO];
            }
            else {
                [self showAlertWithError:error];
            }
            
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"Class: RepositoryListViewController");
        NSLog(@"Method: getSearchReaults");
    }
}

- (void)loadNextPageData {
    
    @try {
        if (self.isPageRequestValid) return;
        if (self.pageNumber > self.totalPage) return;
        self.isPageRequestValid = YES;
        
        DataFetchManager *dataFetchManager = [DataFetchManager new];
        __weak __typeof(&*self)weakSelf = self;
        [dataFetchManager searchRepositoryDataWithString:self.searchBar.text forPageNumber:self.pageNumber withCompletionBlock:^(GHResults *result, BOOL success, NSError *error) {
            
            if (success &&self.isPageRequestValid && [result isKindOfClass:[GHResults class]]) {
                self.pageNumber++;
                
                NSMutableArray *indexPathArray = [ NSMutableArray new];
                for (NSInteger index = weakSelf.repositoryDataArray.count; index < weakSelf.repositoryDataArray.count + result.items.count; index++) {
                    [indexPathArray addObject:[NSIndexPath indexPathForRow:index inSection:0]];
                }
                [weakSelf.repositoryDataArray addObjectsFromArray:result.items];
                // Table begin update..
                [weakSelf.searchTableView beginUpdates];
                [weakSelf.searchTableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone];
                [weakSelf.searchTableView endUpdates];
            }
            else {
                [self showAlertWithError:error];
            }
            
            self.isPageRequestValid = NO;
            
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"Class: RepositoryListViewController");
        NSLog(@"Method: loadNextPageData");
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return (self.repositoryDataArray && [self.repositoryDataArray count])?self.repositoryDataArray.count:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"list" forIndexPath:indexPath];
        GHRepository *repository = [self.repositoryDataArray objectAtIndex:indexPath.row];
        UILabel *repositoryName = [(UILabel *)cell viewWithTag:1001];
        UILabel *repositoryDescrepion = [(UILabel *)cell viewWithTag:1002];
        repositoryName.text = repository.name;
        repositoryDescrepion.text = repository.repositoryDescription;
        return cell;
    }
    @catch (NSException *exception) {
        NSLog(@"Class: RepositoryListViewController");
        NSLog(@"Method: cellForRowAtIndexPath");
    }
    
    
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        if (((self.repositoryDataArray.count - 1) == indexPath.row) && (self.totalPage/PER_PAGE_COUNT>self.pageNumber) && self.searchBar.text.length) {
            [self loadNextPageData];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Class: RepositoryListViewController");
        NSLog(@"Method: willDisplayCell");
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        [self.searchTableView deselectRowAtIndexPath:indexPath animated:YES];
        self.selectedIndexPath = indexPath;
        [self.searchBar resignFirstResponder];
        [self performSegueWithIdentifier:@"RepositoryListToDetailView" sender:self];
    }
    @catch (NSException *exception) {
        NSLog(@"Class: RepositoryListViewController");
        NSLog(@"Method: didSelectRowAtIndexPath");
    }
    
    
    

}

#pragma mark - UISearchBarDelegate Methods
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    
    return TRUE;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    if (self.searchBar.text.length>0)
    {
        [self getSearchReaults];
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"RepositoryListToDetailView"]) {
        RepositoryDetailViewController *detailViewController = (RepositoryDetailViewController *)segue.destinationViewController;
        detailViewController.repository = [self.repositoryDataArray objectAtIndex:self.selectedIndexPath.row];
    }
}


-(void)showAlertWithError:(NSError*)aError {
    [[[UIAlertView alloc] initWithTitle:APPLICATION_NAME message:aError.localizedDescription delegate:nil cancelButtonTitle:OK_MESSAGE otherButtonTitles:nil] show];
}

@end
