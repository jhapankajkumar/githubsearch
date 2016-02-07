//
//  FindMyRepositoryTests.m
//  FindMyRepositoryTests
//
//  Created by Pankaj Kumar Jha on 06/02/16.
//  Copyright © 2016 Pankaj Kumar Jha. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <RestKit/RestKit.h>
#import <RestKit/Testing.h>
#import "GHResults.h"
#import "DataFetchManager.h"

@interface ObjectMappingTest : XCTestCase
@end

@implementation ObjectMappingTest

- (void)setUp {
    [super setUp];
   
    
    
  NSBundle *testTargetBundle = [NSBundle bundleWithIdentifier:@"com.til.repository"];
    [RKTestFixture setFixtureBundle:testTargetBundle];
}


- (RKObjectMapping *)repositoryMapping
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


- (RKObjectMapping *)issuesMapping
{
    //    // setup object mappings
    RKObjectMapping *issueMapping = [RKObjectMapping mappingForClass:[GHIssues class]];
    [issueMapping addAttributeMappingsFromDictionary:@{
                                                       @"title": @"title",
                                                       @"body": @"body"
                                                       }];
    return issueMapping;
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


//Testing for correctly Mapped Object
- (void)testMappingOfTotalCount
{
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"repositories.json"];
    RKMappingTest *test = [RKMappingTest testForMapping:[self repositoryMapping] sourceObject:parsedJSON destinationObject:nil];
    [test addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"total_count" destinationKeyPath:@"totalCount"]];
    XCTAssertTrue([test evaluate], @"totalCount mismatched!");
}


- (void)testMappingOfRepositoryItems
{
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"repositories.json"];
    RKMappingTest *test = [RKMappingTest testForMapping:[self repositoryMapping] sourceObject:parsedJSON destinationObject:nil];
    [test addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"full_name" destinationKeyPath:@"fullName"]];
    
    [test addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"issues_url" destinationKeyPath:@"issuesUrl"]];
    
    [test addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"contributors_url" destinationKeyPath:@"contributorsUrl"]];
    
    [test addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"description" destinationKeyPath:@"repositoryDescription"]];
    
    [test addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"name" destinationKeyPath:@"name"]];
    XCTAssertTrue([test evaluate], @"fullName not mapped!");
    
}


- (void)testMappingOfIssueItems
{
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"issues.json"];
    RKMappingTest *test = [RKMappingTest testForMapping:[self issuesMapping] sourceObject:parsedJSON destinationObject:nil];
    [test addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"title" destinationKeyPath:@"title"]];
    
    [test addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"body" destinationKeyPath:@"body"]];
    
    XCTAssertTrue([test evaluate], @"items not mapped!");
}

- (void)testMappingOfContributorsItems
{
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"contributors.json"];
    RKMappingTest *test = [RKMappingTest testForMapping:[self contributorsMapping] sourceObject:parsedJSON destinationObject:nil];
    [test addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"login" destinationKeyPath:@"login"]];
    
    [test addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"avatar_url" destinationKeyPath:@"avatarUrl"]];
    
    XCTAssertTrue([test evaluate], @"items not mapped!");

}


- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}
@end
