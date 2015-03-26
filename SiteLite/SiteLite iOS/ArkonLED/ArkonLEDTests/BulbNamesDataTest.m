//
//  BulbNamesDataTest.m
//  SiteLite
//
//  Created by Michael Nation on 2/17/15.
//  Copyright (c) 2015 ArkonLED. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BulbNamesData.h"
#import <OCMock/OCMock.h>

@interface BulbNamesDataTest : XCTestCase
@property (nonatomic) BulbNamesData *bulbNamesData;
@property (nonatomic) NSMutableArray *mockBulbs;
@end

@interface BulbNamesData ()
- (NSMutableArray *)bulbTypes;
- (BOOL)bulbTypeIndexIsUsable:(NSUInteger)index;
@end

@implementation BulbNamesDataTest

- (void)setUp {
    [super setUp];
    
    self.bulbNamesData = [[BulbNamesData alloc] init];
    
    //NSLog(@"Count:%lu", self.bulbNames.bulbTypes.count);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAsynchRESTCall {
    XCTestExpectation *expectation = [self expectationWithDescription:@"BulbTypes should load asynchronously under 5 seconds."];
    
    [self.bulbNamesData loadBulbTypes:^(BOOL success){
        XCTAssertTrue(success, @"success variable should be true for bulb types");
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

- (void)testBulbTypeDescriptionAtIndexOne {
    [self createMockBulbs];
    
    id mockBulbNamesToTest = [OCMockObject partialMockForObject:self.bulbNamesData];
    [[[mockBulbNamesToTest stub] andReturn:self.mockBulbs] bulbTypes];
    NSUInteger bulbIndex = 1;
    [[[mockBulbNamesToTest stub] andReturnValue:@(YES)] bulbTypeIndexIsUsable:bulbIndex];
    XCTAssertTrue([[mockBulbNamesToTest bulbTypeDescriptionAtIndex:bulbIndex] isEqualToString:@"High-Pressure Sodium (HPS)"], @"Bulb description should equal the description from index 1.");
}

-(void)createMockBulbs {
    self.mockBulbs = [[NSMutableArray alloc] init];
    [self.mockBulbs addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"0", @"bulb_id", @"Metal Halide", @"bulb_description", nil]];
    [self.mockBulbs addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1", @"bulb_id", @"High-Pressure Sodium (HPS)", @"bulb_description", nil]];
    [self.mockBulbs addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"2", @"bulb_id", @"Halogen", @"bulb_description", nil]];
}
@end
