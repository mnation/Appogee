//
//  LEDFixturesData.h
//  SiteLite
//
//  Created by Michael Nation on 2/26/15.
//  Copyright (c) 2015 ArkonLED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfoGlobal.h"

@interface LEDFixturesData : NSObject

typedef void(^completionBlock)(BOOL);

- (void)loadLEDFixtures:(completionBlock)compBlock;
- (NSUInteger)shoeBoxesCount;
- (NSString *)shoeBoxDescriptionAtIndex:(NSUInteger)index;
- (NSString *)shoeBoxWattageAtIndex:(NSUInteger)index;
- (NSString *)shoeBoxIDAtIndex:(NSUInteger)index;
- (NSUInteger)shoeBoxIndexWithID:(NSString *)shoeBoxID;

- (NSUInteger)wallPacksCount;
- (NSString *)wallPackDescriptionAtIndex:(NSUInteger)index;
- (NSString *)wallPackWattageAtIndex:(NSUInteger)index;
- (NSString *)wallPackIDAtIndex:(NSUInteger)index;
- (NSUInteger)wallPackIndexWithID:(NSString *)wallPackID;

@end
