//
//  Presentation.m
//  SiteLite
//
//  Created by Michael Nation on 11/14/14.
//  Copyright (c) 2014 ArkonLED. All rights reserved.
//

#import "Presentation.h"

@interface Presentation ()

@property (strong, nonatomic) UserInfoGlobal *userInfoGlobal;

@end

@implementation Presentation

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.toolbarHidden = YES;
    
    //Set navbar title with Project Name
    self.navigationItem.title = self.strProjectTitle;
    
    self.userInfoGlobal = [[UserInfoGlobal alloc] init];
    
    NSString *urlAddress = [NSString stringWithFormat:@"%@/home/#/client/%@", [UserInfoGlobal serverURL], self.strProjectID];
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    [self.webView loadRequest:requestObj];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backBtn:(id)sender
{
    self.navigationController.toolbarHidden = NO;
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end