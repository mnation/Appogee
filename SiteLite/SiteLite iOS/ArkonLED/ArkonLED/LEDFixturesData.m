//
//  LEDFixturesData.m
//  SiteLite
//
//  Created by Michael Nation on 2/26/15.
//  Copyright (c) 2015 ArkonLED. All rights reserved.
//

#import "LEDFixturesData.h"

@interface LEDFixturesData()
@property (strong, nonatomic) NSMutableArray *lEDFixtureShoeboxes;
@property (strong, nonatomic) NSMutableArray *lEDFixtureWallPacks;
@end


@implementation LEDFixturesData

- (void)loadLEDFixtures:(completionBlock)compBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/iOS/LightPoles/getLEDFixtures.php", [UserInfoGlobal serverURL]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if(!error)
         {
             NSDictionary *dicServerMessage = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
             
             if([[dicServerMessage objectForKey:@"success"] isEqualToNumber:@1])
             {
                 self.lEDFixtureShoeboxes = [dicServerMessage objectForKey:@"shoebox"];
                 self.lEDFixtureWallPacks = [dicServerMessage objectForKey:@"wallpack"];
                 
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

- (NSUInteger)shoeBoxesCount
{
    return [self.lEDFixtureShoeboxes count];
}

- (NSString *)shoeBoxDescriptionAtIndex:(NSUInteger)index
{
    if([self shoeBoxesIndexIsUsable:index])
    {
        NSDictionary *singleLEDFixtureShoeBox = [self.lEDFixtureShoeboxes objectAtIndex:index];
        return singleLEDFixtureShoeBox[@"LED_fixture_description"];
    }
    else
        return @"";
}


- (NSString *)shoeBoxWattageAtIndex:(NSUInteger)index
{
    if([self shoeBoxesIndexIsUsable:index])
    {
        NSDictionary *singleLEDFixtureShoeBox = [self.lEDFixtureShoeboxes objectAtIndex:index];
        return singleLEDFixtureShoeBox[@"LED_wattage"];
    }
    else
        return @"";
}

- (NSString *)shoeBoxIDAtIndex:(NSUInteger)index
{
    if([self shoeBoxesIndexIsUsable:index])
    {
        NSDictionary *singleLEDFixtureShoeBox = [self.lEDFixtureShoeboxes objectAtIndex:index];
        return singleLEDFixtureShoeBox[@"LED_fixture_ID"];
    }
    else
        return @"";
}

- (NSUInteger)shoeBoxIndexWithID:(NSString *)shoeBoxID
{
    for(int i = 0; i < [self shoeBoxesCount]; i++)
    {
        if([[self shoeBoxIDAtIndex:i] isEqualToString:shoeBoxID])
            return i;
    }
    
    return NSNotFound;
}

- (BOOL)shoeBoxesIndexIsUsable:(NSUInteger)index
{
    return index <= ([self shoeBoxesCount] - 1);
}

- (NSUInteger)wallPacksCount
{
    return [self.lEDFixtureWallPacks count];
}

- (NSString *)wallPackDescriptionAtIndex:(NSUInteger)index
{
    if([self wallPacksIndexIsUsable:index])
    {
        NSDictionary *singleLEDFixtureWallPack = [self.lEDFixtureWallPacks objectAtIndex:index];
        return singleLEDFixtureWallPack[@"LED_fixture_description"];
    }
    else
        return @"";
}

- (NSString *)wallPackWattageAtIndex:(NSUInteger)index
{
    if([self wallPacksIndexIsUsable:index])
    {
        NSDictionary *singleLEDFixtureWallPack = [self.lEDFixtureWallPacks objectAtIndex:index];
        return singleLEDFixtureWallPack[@"LED_wattage"];
    }
    else
        return @"";
}

- (NSString *)wallPackIDAtIndex:(NSUInteger)index
{
    if([self wallPacksIndexIsUsable:index])
    {
        NSDictionary *singleLEDFixtureWallPack = [self.lEDFixtureWallPacks objectAtIndex:index];
        return singleLEDFixtureWallPack[@"LED_fixture_ID"];
    }
    else
        return @"";
}

- (NSUInteger)wallPackIndexWithID:(NSString *)wallPackID
{
    for(int i = 0; i < [self wallPacksCount]; i++)
    {
        if([[self wallPackIDAtIndex:i] isEqualToString:wallPackID])
            return i;
    }
    
    return NSNotFound;
}

- (BOOL)wallPacksIndexIsUsable:(NSUInteger)index
{
    return index <= ([self wallPacksCount] - 1);
}

@end
