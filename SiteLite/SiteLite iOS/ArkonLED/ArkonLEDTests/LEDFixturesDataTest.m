//
//  LEDFixturesDataTest.m
//  SiteLite
//
//  Created by Michael Nation on 2/26/15.
//  Copyright (c) 2015 ArkonLED. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "LEDFixturesData.h"

@interface LEDFixturesDataTest : XCTestCase
@property (nonatomic) LEDFixturesData *ledFixturesData;
@end

@implementation LEDFixturesDataTest

- (void)setUp {
    [super setUp];
    
    self.ledFixturesData = [[LEDFixturesData alloc] init];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"LED Fixture should load asynchronously under 5 seconds."];
    [self.ledFixturesData loadLEDFixtures:^(BOOL success){
        XCTAssertTrue(success, @"success variable should be true for LED Fixtures");
        [expectation fulfill];
    }];
    
    [self waitForTheExpectation];
}

- (void)waitForTheExpectation
{
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", [error localizedDescription]);
        }
    }];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testLEDFixtureShoeBoxesCountGreaterThanZero {
    XCTAssertGreaterThan([self.ledFixturesData shoeBoxesCount], 0, @"LED Fixture Shoeboxes count should be greater than 0");
}

- (void)testLEDFixtureWallPacksCountGreaterThanZero {
    XCTAssertGreaterThan([self.ledFixturesData wallPacksCount], 0, @"LED Fixture WallPacks count should be greater than 0");
}

@end
