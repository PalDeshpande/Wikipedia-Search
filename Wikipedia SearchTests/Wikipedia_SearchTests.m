//
//  Wikipedia_SearchTests.m
//  Wikipedia SearchTests
//
//  Created by Pallavi Keskar on 1/30/15.
//  Copyright (c) 2015 pallavi.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "PKWikiSearchTableViewController.h"
#import "AFNetworking.h"


@interface PKWikiSearchTableViewController (Test)
@property (strong, nonatomic) NSMutableArray *searchResults;

- (NSString *)timeStampToDate:(NSString *)timeStamp;
- (void )fetchDataWithParameters:(id)parameters
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
@interface Wikipedia_SearchTests : XCTestCase
@property (nonatomic)PKWikiSearchTableViewController *searchVC;
@end

@implementation Wikipedia_SearchTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.searchVC = [[PKWikiSearchTableViewController alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTimeStampToDate {
    NSString *timestamp = @"2015-01-24T02:47:17Z";
    NSString *actual = [self.searchVC timeStampToDate:timestamp];
    NSString *expectedDate = @"1/23/15, 6:47 PM";
    XCTAssertEqualObjects(expectedDate, actual);
}

- (void)testfetchData {
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"long method"];
    NSDictionary *parameters = @{
                                 @"format" : @"json",
                                 @"action" : @"query",
                                 @"srprop" : @"timestamp",
                                 @"srsearch" : @"search",
                                 @"list" : @"search"
                                 };
    [self.searchVC fetchDataWithParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        XCTAssertEqual([(NSDictionary *)responseObject[@"query"][@"search"] count], 10);
        [completionExpectation fulfill];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error");
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];

}

- (void)testfetchDataWithNoSearchTitle {
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"long method"];
    NSString *searchItem = @"";
    NSDictionary *parameters = @{
                                 @"format" : @"json",
                                 @"action" : @"query",
                                 @"srprop" : @"timestamp",
                                 @"srsearch" :searchItem,
                                 @"list" : @"search"
                                 };
    [self.searchVC fetchDataWithParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        XCTAssertEqual([(NSDictionary *)responseObject[@"query"][@"search"] count], 0);
        [completionExpectation fulfill];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error");
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    
}



- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
