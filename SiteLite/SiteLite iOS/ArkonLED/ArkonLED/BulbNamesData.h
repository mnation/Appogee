//
//  BulbNamesData.h
//  SiteLite
//
//  Created by Michael Nation on 2/6/15.
//  Copyright (c) 2015 ArkonLED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfoGlobal.h"

@interface BulbNamesData : NSObject
typedef void(^completionBlock)(BOOL);

- (void)loadBulbTypes:(completionBlock)compBlock;
- (NSUInteger)bulbTypesCount;
- (NSString *)bulbTypeDescriptionAtIndex:(NSUInteger)index;
- (NSString *)bulbTypeIDAtIndex:(NSUInteger)index;
- (NSUInteger)bulbTypeIndexWithID:(NSString *)bulbTypeID;

@end
