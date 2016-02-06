//
//  GHRepository.h
//  FindMyRepository
//
//  Created by Pankaj Kumar Jha on 06/02/16.
//  Copyright © 2016 Pankaj Kumar Jha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GHRepository : NSObject
@property (nonatomic,strong) NSString * name;
@property (nonatomic,strong) NSString * fullName;
@property (nonatomic,strong) NSString * repositoryDescription;
@property (nonatomic,strong) NSString * issuesUrl;
@property (nonatomic,strong) NSString * contributorsUrl;
@end
