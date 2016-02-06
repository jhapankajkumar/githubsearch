//
//  RepositoryListViewController.h
//  FindMyRepository
//
//  Created by Pankaj Kumar Jha on 06/02/16.
//  Copyright © 2016 Pankaj Kumar Jha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepositoryListViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *searchTableView;
@property (weak, nonatomic) IBOutlet UILabel *cancel;
@end
