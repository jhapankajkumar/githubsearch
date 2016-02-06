//
//  Results.h
//  FindMyRepository
//
//  Created by Pankaj Kumar Jha on 06/02/16.
//  Copyright © 2016 Pankaj Kumar Jha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "GHRepository.h"


@interface GHResults : NSObject
@property (nonatomic,strong) NSNumber * totalCount;
@property (nonatomic) BOOL isIncompleteResults;
@property (nonatomic,strong) NSArray <GHRepository *>  *items;
@end
