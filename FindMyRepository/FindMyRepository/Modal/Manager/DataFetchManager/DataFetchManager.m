//
//  DataFetchManager.m
//  FindMyRepository
//
//  Created by Pankaj Kumar Jha on 06/02/16.
//  Copyright © 2016 Pankaj Kumar Jha. All rights reserved.
//


#import "DataFetchManager.h"
#import "Constants.h"

#define AccessToken  @"80f1c9a49d0e54a43814c30d0aad12bd127cde34"

@implementation DataFetchManager

-(void)searchRepositoryDataWithString:(NSString *)aSearchedString forPageNumber:(NSUInteger)pageNumber withCompletionBlock:(void(^) (GHResults* result,BOOL success, NSError *error))completionBlock {
    
    @try {
        // initialize AFNetworking HTTPClient
        NSURL *baseURL = [NSURL URLWithString:@"https://api.github.com"];
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
        
        // initialize RestKit
        RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
        
        //    // setup object mappings
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[GHResults class]];
        [resultMapping addAttributeMappingsFromDictionary:@{
                                                            @"total_count": @"totalCount",
                                                            @"incomplete_result": @"isIncompleteResults",
                                                            }];;
        
        NSLog(@"page no :%lu",(unsigned long)pageNumber);
        RKObjectMapping *repositoryMapping = [RKObjectMapping mappingForClass:[GHRepository class]];
        
        [repositoryMapping addAttributeMappingsFromDictionary:@{
                                                                @"name": @"name",
                                                                @"full_name": @"fullName",
                                                                @"description": @"repositoryDescription",
                                                                @"issues_url": @"issuesUrl",
                                                                @"contributors_url": @"contributorsUrl"
                                                                }];
        
        //link mapping with a relationship
        RKRelationshipMapping *rel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"items" toKeyPath:@"items" withMapping:repositoryMapping];
        
        //add relationship mapping to article
        [resultMapping addPropertyMapping:rel];
        
        // register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptor =
        [RKResponseDescriptor responseDescriptorWithMapping:resultMapping
                                                     method:RKRequestMethodGET
                                                pathPattern:nil
                                                    keyPath:nil
                                                statusCodes:[NSIndexSet indexSetWithIndex:200]];
        
        [objectManager addResponseDescriptor:responseDescriptor];
        
        NSDictionary *queryParams = @{@"q" : aSearchedString,
                                      @"access_token":AccessToken,
                                      @"sort" : @"stars",
                                      @"order" : @"desc",
                                      @"per_page":[NSString stringWithFormat:@"%lu",(unsigned long)PER_PAGE_COUNT],
                                      @"page":[NSString stringWithFormat:@"%lu",(unsigned long)pageNumber]
                                      };
        
        [objectManager getObjectsAtPath:@"/search/repositories"
                             parameters:queryParams
                                success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                    GHResults *results = [mappingResult.array firstObject];
                                    // NSLog(@"%@",mappingResult.array);
                                    
                                    if (results.isIncompleteResults == false) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            completionBlock(results,true,nil);
                                        });
                                    }
                                    else {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            completionBlock(results,false,nil);
                                        });
                                    }
                                }
                                failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                    NSLog(@"Error: %@", error);
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        completionBlock(nil,false,error);
                                    });
                                }];
    }
    @catch (NSException *exception) {
        NSLog(@"Class: DataFetchManager");
        NSLog(@"Method: SearchRepositoryData");
    }
}


-(void)getIssuListFromURL:(NSString *)aUrl withCompletionBlock:(void(^) (NSArray* issues,BOOL success, NSError *error))completionBlock {
    
    @try {
        
        
        //    // setup object mappings
        RKObjectMapping *issueMapping = [RKObjectMapping mappingForClass:[GHIssues class]];
        [issueMapping addAttributeMappingsFromDictionary:@{
                                                           @"title": @"title",
                                                           @"body": @"body",
                                                           }];
        // register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptor =
        [RKResponseDescriptor responseDescriptorWithMapping:issueMapping
                                                     method:RKRequestMethodGET
                                                pathPattern:nil
                                                    keyPath:nil
                                                statusCodes:[NSIndexSet indexSetWithIndex:200]];
        NSString *issueUrl = aUrl;
        NSArray *urlArray = [aUrl componentsSeparatedByString:@"{"];
        if (urlArray.count>1) {
            issueUrl  = [urlArray objectAtIndex:0];
        }
       
        NSURL *url = [NSURL URLWithString:issueUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
        [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
            
            NSArray *dataArray = [NSArray arrayWithArray:result.array];
            NSMutableArray *issueArray = [NSMutableArray new];
            
            NSUInteger upperLimit = 0;
            if (dataArray.count>3) {
                upperLimit = 3;
            }
            else {
                upperLimit = dataArray.count;
            }
            
            for (int i= 0; i<upperLimit; i++) {
                [issueArray addObject:[dataArray objectAtIndex:i]];
            }
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(issueArray,true,nil);
                });
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(nil,false,error);
            });
        }];
        [operation start];
    }
    @catch (NSException *exception) {
        NSLog(@"Class: DataFetchManager");
        NSLog(@"Method: getIssuListFromURL");
    }
    
}

-(void)getContributorsFromURL:(NSString *)aUrl withCompletionBlock:(void(^) (NSArray* contributors,BOOL success, NSError *error))completionBlock {
    
    @try {
        
        
        //    // setup object mappings
        RKObjectMapping *issueMapping = [RKObjectMapping mappingForClass:[GHContributors class]];
        [issueMapping addAttributeMappingsFromDictionary:@{
                                                           @"login": @"login",
                                                           @"avatar_url": @"avatarUrl",
                                                           }];
        // register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptor =
        [RKResponseDescriptor responseDescriptorWithMapping:issueMapping
                                                     method:RKRequestMethodGET
                                                pathPattern:nil
                                                    keyPath:nil
                                                statusCodes:[NSIndexSet indexSetWithIndex:200]];
        
        NSString *issueUrl = aUrl;
        NSArray *urlArray = [aUrl componentsSeparatedByString:@"{"];
        if (urlArray.count>1) {
            issueUrl  = [urlArray objectAtIndex:0];
        }
        
        NSURL *url = [NSURL URLWithString:issueUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
        [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
            
            NSArray *dataArray = [NSArray arrayWithArray:result.array];
            
            NSMutableArray *contributorsArray = [NSMutableArray new];
            
            NSUInteger upperLimit = 0;
            if (dataArray.count>3) {
                upperLimit = 3;
            }
            else {
                upperLimit = dataArray.count;
            }
            
            for (int i= 0; i<upperLimit; i++) {
                [contributorsArray addObject:[dataArray objectAtIndex:i]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(contributorsArray,true,nil);
            });
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            completionBlock(nil,false,error);
        }];
        [operation start];
        
       
    }
    @catch (NSException *exception) {
        NSLog(@"Class: DataFetchManager");
        NSLog(@"Method: getContributorsFromURL");
    }
    
}


-(void)downloadImageWithURL:(NSString *)anImageURL forIndexPath:(NSIndexPath *)anIndexPath withCompletionBock:(void (^) (UIImage *image, NSIndexPath *indexPath, NSError *error))completionBlock {
    
    NSURL *url = [NSURL URLWithString:anImageURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (error==nil) {
            UIImage *image = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(image,anIndexPath,nil);
            });
            
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(nil,anIndexPath,error);
            });
        }
        
        
    } ];

    [dataTask resume];
}


@end
