//
//  RepositoryDetailViewController.h
//  FindMyRepository
//
//  Created by Pankaj Kumar Jha on 06/02/16.
//  Copyright © 2016 Pankaj Kumar Jha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHRepository.h"

@interface RepositoryDetailViewController : UIViewController
@property (nonatomic,strong) GHRepository *repository;
@end
