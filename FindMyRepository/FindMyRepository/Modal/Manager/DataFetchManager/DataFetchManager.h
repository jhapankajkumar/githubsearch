//
//  DataFetchManager.h
//  FindMyRepository
//
//  Created by Pankaj Kumar Jha on 06/02/16.
//  Copyright © 2016 Pankaj Kumar Jha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "GHResults.h"
#import "GHIssues.h"
#import "GHContributors.h"
@interface DataFetchManager : NSObject

/*
 * searchRepositoryDataWithString:(NSString *)aSearchedString : CompletionBlock : This functions helps us to search data from server. This a block based function.
 * @params
 aSearchedString: repository to search with this string
 pageNumber: data to be fetched for this page number
 CompletionBlock
 * @response
 - status - This is BOOL value, indicating the Regestration was sucessful or not, If YES, sucessful.
 - restult -  Repository results data received from sever
 - error - This gives an error in case user regestration fails, or if some thing is not set.
 */
-(void)searchRepositoryDataWithString:(NSString *)aSearchedString forPageNumber:(NSUInteger )pageNumber withCompletionBlock:(void(^) (GHResults* result,BOOL success, NSError *error))completionBlock;



-(void)getIssuListFromURL:(NSString *)aUrl withCompletionBlock:(void(^) (NSArray* issues,BOOL success, NSError *error))completionBlock;

-(void)getContributorsFromURL:(NSString *)aUrl withCompletionBlock:(void(^) (NSArray* contributors,BOOL success, NSError *error))completionBlock;

-(void)downloadImageWithURL:(NSString *)anImageURL forIndexPath:(NSIndexPath *)anIndexPath withCompletionBock:(void (^) (UIImage *image, NSIndexPath *indexPath, NSError *error))completionBlock;


@end
