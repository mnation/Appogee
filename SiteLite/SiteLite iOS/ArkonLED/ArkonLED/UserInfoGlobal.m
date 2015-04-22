//
//  UserInfoGlobal.m
//  Pi Delta Psi
//
//  Created by Michael Nation on 3/15/14.
//  Copyright (c) 2014 Mike Nation Industries. All rights reserved.
//

#import "UserInfoGlobal.h"

static NSString *userID;
static NSString *userType;
//static NSString *serverURL = @"http://ec2-54-84-156-215.compute-1.amazonaws.com"; //Prod
static NSString *serverURL = @"http://ec2-52-4-175-61.compute-1.amazonaws.com/"; //Dev

@implementation UserInfoGlobal

+ (void)setUserID:(NSString *)UserID
{
    userID = UserID;
}

+ (NSString *)userID
{
    return userID;
}

+ (void)setUserType:(NSString *)UserType
{
    userType = UserType;
}

+ (NSString *)userType
{
    return userType;
}

+ (NSString *)serverURL
{
    return serverURL;
}

@end
