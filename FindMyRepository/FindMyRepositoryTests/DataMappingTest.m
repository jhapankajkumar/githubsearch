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
#import "RepositoryListViewController.h"
#import "DataFetchManager.h"

@interface DataMappingTest : XCTestCase
@property (nonatomic, strong) RepositoryListViewController *vc;
@end

@implementation DataMappingTest

- (void)setUp {
    [super setUp];
    
    
    
    NSBundle *testTargetBundle = [NSBundle bundleWithIdentifier:@"com.til.repository"];
    [RKTestFixture setFixtureBundle:testTargetBundle];
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


- (void)testDataForTotalNumberOfResults {
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"repositories.json"];
    RKMappingTest *test = [RKMappingTest testForMapping:[self resultMapping] sourceObject:parsedJSON destinationObject:nil];
    
    // Check the value as well as the keyPaths
    [test addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"total_count" destinationKeyPath:@"totalCount" value:[NSNumber numberWithInt:267289]]];
    
    XCTAssertTrue([test evaluate], @"value not matched");
}


- (void)testDataValueForRepositoryItems {
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"repositories.json"];
    RKMappingTest *test = [RKMappingTest testForMapping:[self resultMapping] sourceObject:parsedJSON destinationObject:nil];
    
    // Check the value as well as the keyPaths
    [test addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"full_name" destinationKeyPath:@"fullName" value:@"airbnb/javascript"]];
    
    [test addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"name" destinationKeyPath:@"name" value:@"javascript"]];
    
    [test addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"description" destinationKeyPath:@"repositoryDescription" value:@"JavaScript Style Guide"]];
    
    [test addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"issues_url" destinationKeyPath:@"issuesUrl" value:@"https://api.github.com/repos/airbnb/javascript/issues{/number}"]];
    
    [test addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"contributors_url" destinationKeyPath:@"contributorsUrl" value:@"https://api.github.com/repos/airbnb/javascript/contributors"]];
    
    XCTAssertTrue([test evaluate], @"value not matched");
}


- (void)testDataValueForIssueItems {
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"issues.json"];
    RKMappingTest *test = [RKMappingTest testForMapping:[self issuesMapping] sourceObject:parsedJSON destinationObject:nil];
    
    // Check the value as well as the keyPaths
    [test addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"title" destinationKeyPath:@"title" value:@"Template Strings Spacing"]];
    
    [test addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"body" destinationKeyPath:@"body" value:@"In Template Strings:\r\n\r\n```javascript\r\n// good\r\nfunction sayHi(name) {\r\n  return `How are you, ${name}?`;\r\n}\r\n```\r\n\r\nDo you prefer `${name}` over `${ name }` ?\r\n\r\nFor variables that seems obvious (no space), but template strings allows much more, like `${ (name) ? name : 'No name' }`, where i think spacing makes it more clear.\r\n\r\n> I didn't test that expression, i can be wrong :stuck_out_tongue:\r\n"]];
    
    
    XCTAssertTrue([test evaluate], @"value not matched");
}


- (void)testDataValueForContributorsItems {
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"contributors.json"];
    RKMappingTest *test = [RKMappingTest testForMapping:[self contributorsMapping] sourceObject:parsedJSON destinationObject:nil];
    
    // Check the value as well as the keyPaths
    [test addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"login" destinationKeyPath:@"login" value:@"hshoff"]];
    
    [test addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"avatar_url" destinationKeyPath:@"avatarUrl" value:@"https://avatars.githubusercontent.com/u/339208?v=3"]];
    
    
    XCTAssertTrue([test evaluate], @"value not matched");
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}








@end
