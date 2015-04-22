//
//  BulbNamesData.m
//  SiteLite
//
//  Created by Michael Nation on 2/6/15.
//  Copyright (c) 2015 ArkonLED. All rights reserved.
//

#import "BulbNamesData.h"

@interface BulbNamesData()
@property (strong, nonatomic) NSMutableArray *bulbTypes;
@end

@implementation BulbNamesData

- (void)loadBulbTypes:(completionBlock)compBlock
{
    //Legacy Fixtures
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/iOS/LightPoles/getLegacyFixtures.php", [UserInfoGlobal serverURL]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if(!error)
         {
             NSDictionary *dicServerMessage = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
             
             if([[dicServerMessage objectForKey:@"success"] isEqualToNumber:@1])
             {
                 self.bulbTypes = [dicServerMessage objectForKey:@"legacyFixtures"];
                 
                 compBlock(YES);
             }
             //Failed
             else
             {
                 UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"WARNING" message:[dicServerMessage objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                 [errorView show];
                 
                 compBlock(NO);
             }
         }
         else
         {
             UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"ERROR" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
             [errorView show];
             
             compBlock(NO);
         }
     }];
}

- (NSUInteger)bulbTypesCount
{
    return [self.bulbTypes count];
}

- (NSString *)bulbTypeDescriptionAtIndex:(NSUInteger)index
{
    if([self bulbTypeIndexIsUsable:index])
    {
        NSDictionary *singleBulbType = [self.bulbTypes objectAtIndex:index];
        return singleBulbType[@"bulb_description"];
    }
    else
        return @"";
}

- (NSString *)bulbTypeIDAtIndex:(NSUInteger)index
{
    if([self bulbTypeIndexIsUsable:index])
    {
        NSDictionary *singleBulbType = [self.bulbTypes objectAtIndex:index];
        return singleBulbType[@"bulb_ID"];
    }
    else
        return @"";
}

- (NSUInteger)bulbTypeIndexWithID:(NSString *)bulbTypeID
{
    for(int i = 0; i < [self bulbTypesCount]; i++)
    {
        if([[self bulbTypeIDAtIndex:i] isEqualToString:bulbTypeID])
            return i;
    }
    
    return NSNotFound;
}

- (BOOL)bulbTypeIndexIsUsable:(NSUInteger)index
{
    return index <= ([self bulbTypesCount] - 1);
}

@end
