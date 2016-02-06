//
//  RepositoryDetailViewController.m
//  FindMyRepository
//
//  Created by Pankaj Kumar Jha on 06/02/16.
//  Copyright © 2016 Pankaj Kumar Jha. All rights reserved.
//

#import "RepositoryDetailViewController.h"
#import "DataFetchManager.h"
#import "GHIssues.h"
#import <MBProgressHUD/MBProgressHUD.h>
@interface RepositoryDetailViewController () {
    DataFetchManager *dataFetchManager;
}

@property (strong, nonatomic) NSMutableArray *issueArray;
@property (strong, nonatomic) NSMutableArray *contributorsArray;
@property (weak, nonatomic) IBOutlet UITableView *detailTableView;



@end

@implementation RepositoryDetailViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.repository.name;
    self.detailTableView.rowHeight = UITableViewAutomaticDimension;
    self.detailTableView.estimatedRowHeight = 80;
    dataFetchManager = [[DataFetchManager alloc]init];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    
    //getting contributers
    [dataFetchManager getContributorsFromURL:self.repository.contributorsUrl withCompletionBlock:^(NSArray *contributors, BOOL success, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (success && contributors.count) {
            self.contributorsArray = [[NSMutableArray alloc]initWithArray:contributors];
            [self.detailTableView reloadData];
        }
    }];
    
    //getting issues
    [dataFetchManager getIssuListFromURL:self.repository.issuesUrl withCompletionBlock:^(NSArray *issues, BOOL success, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (success && issues.count) {
            self.issueArray = [[NSMutableArray alloc]initWithArray:issues];
            [self.detailTableView reloadData];
        }
        
    }];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 1;
            break;
            
        case 1:
            return self.contributorsArray.count;
            break;
        case 2:
            return self.issueArray.count;
            break;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        
        switch (indexPath.section) {
            case 0: {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"list" forIndexPath:indexPath];
                GHRepository *repository = self.repository;
                UILabel *repositoryName = [(UILabel *)cell viewWithTag:1001];
                UILabel *repositoryDescrepion = [(UILabel *)cell viewWithTag:1002];
                repositoryName.text = repository.name;
                repositoryDescrepion.text = repository.repositoryDescription;
                return cell;
            }
                
                break;
                
            case 1:
            {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contributors" forIndexPath:indexPath];
                
                GHContributors *contributors = [self.contributorsArray objectAtIndex:indexPath.row];
                
                UILabel *firstContributorName = [(UILabel *)cell viewWithTag:1002];
                UIActivityIndicatorView *indicator = [(UIActivityIndicatorView *)cell viewWithTag:1003];
                
                [indicator startAnimating];
                firstContributorName.text =  contributors.login;
                
                __weak __typeof(&*self)weakSelf = self;
                
                
                [dataFetchManager downloadImageWithURL:contributors.avatarUrl forIndexPath:indexPath withCompletionBock:^(UIImage *image, NSIndexPath *indexPath, NSError *error) {
                    
                    if (image) {
                        UITableViewCell *cellOld = [weakSelf.detailTableView cellForRowAtIndexPath:indexPath];
                        UIActivityIndicatorView *indicator = [(UIActivityIndicatorView *)cellOld viewWithTag:1003];
                        [indicator stopAnimating];
                        indicator.hidden = true;
                        if (cellOld) {
                            UIImageView *firstContributorImage = [(UIImageView *)cellOld viewWithTag:1001];
                            firstContributorImage.image = image;
                        }
                    }
                    
                    
                    
                }];
                
                
                return cell;
            }
                break;
                
            case 2:
            {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"list" forIndexPath:indexPath];
                GHIssues *repository = [self.issueArray objectAtIndex:indexPath.row];
                UILabel *repositoryName = [(UILabel *)cell viewWithTag:1001];
                UILabel *repositoryDescrepion = [(UILabel *)cell viewWithTag:1002];
                repositoryName.text = repository.title;
                repositoryDescrepion.text = repository.body;
                return cell;
            }
                break;
                
            default:
                break;
        }
        
        
    }
    @catch (NSException *exception) {
        NSLog(@"Class: RepositoryDetailViewController");
        NSLog(@"Method: cellForRowAtIndexPath");
    }
    
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    
    @try {
        switch (section) {
            case 0:
                return @"";
                break;
            case 1:
                return @"Top Contributors";
                break;
            case 2:
                return @"Recent Issues";
                break;
                
            default:
                break;
        }
        return @"";
    }
    @catch (NSException *exception) {
        NSLog(@"Class: RepositoryDetailViewController");
        NSLog(@"Method: titleForHeaderInSection");
    }
    
    
    
    
}


@end
