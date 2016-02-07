//
//  FindMyRepositoryTests.m
//  FindMyRepositoryTests
//
//  Created by Pankaj Kumar Jha on 06/02/16.
//  Copyright © 2016 Pankaj Kumar Jha. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <RestKit/RestKit.h>
#import "GHResults.h"
#import "GHContributors.h"


@interface NetworkTest : XCTestCase

@end

@implementation NetworkTest

- (void)setUp {
    [super setUp];
    
    
    
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (RKObjectMapping *)resultMapping
{
    // Step 3: setup object mappings
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[GHResults class]];
    [resultMapping addAttributeMappingsFromDictionary:@{
                                                        @"total_count": @"totalCount",
                                                        @"incomplete_result": @"isIncompleteResults",
                                                        }];;
    
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
    return resultMapping;
}


- (RKObjectMapping *)contributorsMapping
{
    //    // setup object mappings
    RKObjectMapping *contributorsMapping = [RKObjectMapping mappingForClass:[GHContributors class]];
    [contributorsMapping addAttributeMappingsFromDictionary:@{
                                                              @"login": @"login",
                                                              @"avatar_url": @"avatarUrl"
                                                              }];
    return contributorsMapping;
}

- (void)testArticleObjectRequestOperation
{
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[self contributorsMapping] pathPattern:nil keyPath:nil statusCodes:[NSIndexSet indexSetWithIndex:200]];
    NSURL *URL = [NSURL URLWithString:@"https://api.github.com/repos/airbnb/javascript/contributors"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    RKObjectRequestOperation *requestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor ]];
    
    [requestOperation start];
    [requestOperation waitUntilFinished];
    XCTAssertTrue(requestOperation.HTTPRequestOperation.response.statusCode == 200, @"Expected 200 response");
    XCTAssertEqual([requestOperation.mappingResult count], 30, @"Expected to load one article");
}






- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}









@end
