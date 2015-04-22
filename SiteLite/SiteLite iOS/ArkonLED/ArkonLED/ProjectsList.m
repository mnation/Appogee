//
//  ProjectsList.m
//  ArkonLED
//
//  Created by Michael Nation on 9/7/14.
//  Copyright (c) 2014 ArkonLED. All rights reserved.
//

#import "ProjectsList.h"

@interface ProjectsList ()

@property (nonatomic) NSIndexPath *indexPathOfCellBeingDeleted;

@end


@implementation ProjectsList

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    self.strAssemblyType = @"ACTIVE";
    
    self.lblBackgroundMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    self.lblBackgroundMessage.text = @"";
    self.lblBackgroundMessage.textColor = [UIColor blackColor];
    self.lblBackgroundMessage.numberOfLines = 0;
    self.lblBackgroundMessage.textAlignment = NSTextAlignmentCenter;
    self.lblBackgroundMessage.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
    [self.lblBackgroundMessage sizeToFit];
    self.tableView.backgroundView = self.lblBackgroundMessage;
    
    //Hide seperator lines for empty cells
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.refreshControl addTarget:self action:@selector(pullToRefreshStart) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self loadProjects];
}

- (void)loadProjects
{
    self.navigationController.toolbarHidden = NO;
    
    //Get Projects
    NSString *strURL = [NSString stringWithFormat:@"%@/iOS/Projects/getProjectNamesByStatus.php?userID=%@", [UserInfoGlobal serverURL], [UserInfoGlobal userID]];
    
    // Create Data from request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:strURL]];
    // set Request Type
    [request setHTTPMethod: @"GET"];
    // Set content-type
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    // Now send a request and get Response
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData * data,NSError * error)
     {
         if(self.refreshControl.isRefreshing)
             [self.refreshControl endRefreshing];
         
         if(!error)
         {
             NSDictionary *dicServerMessage = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
             
             //Successful
             if([[dicServerMessage objectForKey:@"success"] isEqualToNumber:@1])
             {
                 self.activeProjects = [dicServerMessage objectForKey:@"active"];
                 self.inactiveProjects = [dicServerMessage objectForKey:@"inactive"];
                 self.closedProjects = [dicServerMessage objectForKey:@"closed"];
                 
                 [self.tableView reloadData];
             }
             //Failed
             else
             {
                 UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"WARNING" message:[dicServerMessage objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                 
                 [errorView show];
             }
         }
         else
         {
             UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"ERROR" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
             
             [errorView show];
             
         }
     }];
    
    //Get Info For Email
    NSString *strURL2 = [NSString stringWithFormat:@"%@/iOS/Projects/getCostsAndAssumptions.php?userID=%@", [UserInfoGlobal serverURL], [UserInfoGlobal userID]];
    
    // Create Data from request
    NSMutableURLRequest *request2 = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:strURL2]];
    // set Request Type
    [request2 setHTTPMethod: @"GET"];
    // Set content-type
    [request2 setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    // Now send a request and get Response
    [NSURLConnection sendAsynchronousRequest:request2 queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData * data,NSError * error)
     {
         if(!error)
         {
             self.dicEmailClient = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
             
             ////Failed
             if([[self.dicEmailClient objectForKey:@"success"] isEqualToNumber:@0])
             {
                 UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"WARNING" message:[self.dicEmailClient objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                 
                 [errorView show];
             }
         }
         else
         {
             UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"ERROR" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
             
             [errorView show];
             
         }
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pullToRefreshStart
{
    [self loadProjects];
}

- (IBAction)profileBtnClicked:(id)sender
{
    //Hide nav bar
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    //Hide Tool bar
    self.navigationController.toolbarHidden = YES;
    
    //Delete keychain if exist
    if([SSKeychain passwordForService:@"arkonled" account:@"email"] != nil)
    {
        [SSKeychain deletePasswordForService:@"arkonled" account:@"email"];
        [SSKeychain deletePasswordForService:@"arkonled" account:@"password"];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)createNewProject:(id)sender
{
    [self performSegueWithIdentifier:@"NewProjectToMapNew" sender:self];
}


//TableView Methods*************************************************************************
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 8, 0, 0)];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 8, 0, 0)];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 105;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self.strAssemblyType isEqualToString:@"ACTIVE"])
    {
        if(self.activeProjects.count == 0)
            self.lblBackgroundMessage.text = @"No projects to display";
        else
            self.lblBackgroundMessage.text = @"";
        
        return self.activeProjects.count;
    }
    else if([self.strAssemblyType isEqualToString:@"INACTIVE"])
    {
        if(self.inactiveProjects.count == 0)
            self.lblBackgroundMessage.text = @"No projects to display";
        else
            self.lblBackgroundMessage.text = @"";
        
        return self.inactiveProjects.count;
    }
    else if([self.strAssemblyType isEqualToString:@"CLOSED"])
    {
        if(self.closedProjects.count == 0)
            self.lblBackgroundMessage.text = @"No projects to display";
        else
            self.lblBackgroundMessage.text = @"";
        
        return self.closedProjects.count;
    }
    //ERROR
    else
    {
        return 0;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    MGSwipeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *dicProjectInfo;
    if([self.strAssemblyType isEqualToString:@"ACTIVE"])
    {
        dicProjectInfo = [self.activeProjects objectAtIndex:indexPath.row];
    }
    else if([self.strAssemblyType isEqualToString:@"INACTIVE"])
    {
        dicProjectInfo = [self.inactiveProjects objectAtIndex:indexPath.row];
    }
    else if([self.strAssemblyType isEqualToString:@"CLOSED"])
    {
        dicProjectInfo = [self.closedProjects objectAtIndex:indexPath.row];
    }
    //ERROR
    else
    {
        dicProjectInfo = nil;
        return cell;
    }
    
    UILabel *lblTitle = (UILabel *)[cell viewWithTag:1];
    lblTitle.text = [dicProjectInfo objectForKey:@"project_name"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate *date = [formatter dateFromString:[dicProjectInfo objectForKey:@"date_opened"]];
    //[formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    UILabel *lblDateOpen = (UILabel *)[cell viewWithTag:2];
    lblDateOpen.text = [formatter stringFromDate:date];
    
    UILabel *lblName = (UILabel *)[cell viewWithTag:3];
    if([[UserInfoGlobal userType] isEqualToString:@"3"]) //Sales Rep, display Contact Name
    {
        lblName.text = [dicProjectInfo objectForKey:@"contact_name"];
    }
    else //Admin, display Salesman's Name
    {
        lblName.text = [NSString stringWithFormat:@"%@ %@", [dicProjectInfo objectForKey:@"first_name"], [dicProjectInfo objectForKey:@"last_name"]];
    }
    
    UILabel *lblLocation = (UILabel *)[cell viewWithTag:6];
    if(![[dicProjectInfo objectForKey:@"city"] isEqualToString:@""])
    {
        lblLocation.text = [NSString stringWithFormat:@"%@, %@",[dicProjectInfo objectForKey:@"city"], [dicProjectInfo objectForKey:@"state"]];
    }
    else
    {
        lblLocation.text = @"";
    }
    
    #if !TEST_USE_MG_DELEGATE
        cell.leftButtons = [self createLeftButtons];
        //cell.leftExpansion.fillOnTrigger = NO;
    #endif
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"DELETE";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        self.indexPathOfCellBeingDeleted = indexPath;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CONFIRM" message:[NSString stringWithFormat:@"Are you sure you want to delete this project?"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
        [alert show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Cancel
    if(buttonIndex == 0)
    {
        [self.tableView setEditing:NO animated:YES];
    }
    //Delete
    else if(buttonIndex == 1)
    {
        NSDictionary *dicProjectInfo;
        // Remove from array
        NSMutableArray *arrayToBeDeleted;
        if([self.strAssemblyType isEqualToString:@"ACTIVE"])
        {
            dicProjectInfo = [self.activeProjects objectAtIndex:self.indexPathOfCellBeingDeleted.row];
            arrayToBeDeleted = self.activeProjects;
        }
        else if([self.strAssemblyType isEqualToString:@"INACTIVE"])
        {
            dicProjectInfo = [self.inactiveProjects objectAtIndex:self.indexPathOfCellBeingDeleted.row];
            arrayToBeDeleted = self.inactiveProjects;
        }
        else if([self.strAssemblyType isEqualToString:@"CLOSED"])
        {
            dicProjectInfo = [self.closedProjects objectAtIndex:self.indexPathOfCellBeingDeleted.row];
            arrayToBeDeleted = self.closedProjects;
        }
        
        NSString *myRequestString = [NSString stringWithFormat:@"projectID=%@&userID=%@", dicProjectInfo[@"project_ID"], [UserInfoGlobal userID]];
        
        // Create Data from request
        NSData *myRequestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
        NSString *URL = [NSString stringWithFormat:@"%@/iOS/Projects/deleteProject.php", [UserInfoGlobal serverURL]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];
        // set Request Type
        [request setHTTPMethod:@"POST"];
        // Set content-type
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        // Set Request Body
        [request setHTTPBody: myRequestData];
        // Now send a request and get Response
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData * data,NSError * error)
         {
             if(!error)
             {
                 NSDictionary *dicServerMessage = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                 
                 //Delete failed
                 if([[dicServerMessage objectForKey:@"success"] isEqualToNumber:@0])
                 {
                     UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"WARNING" message:[dicServerMessage objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                     
                     [errorView show];
                 }
                 //Delete the cell on tableView
                 else
                 {
                     [arrayToBeDeleted removeObjectAtIndex:self.indexPathOfCellBeingDeleted.row];
                     [self.tableView deleteRowsAtIndexPaths:@[self.indexPathOfCellBeingDeleted] withRowAnimation:UITableViewRowAnimationFade];
                 }
             }
             else
             {
                 UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"ERROR" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                 
                 [errorView show];
                 
             }
             
             self.indexPathOfCellBeingDeleted = nil;
         }];
    }
}

- (NSArray *)createLeftButtons
{
    NSMutableArray * result = [NSMutableArray array];
    
    if(![self.strAssemblyType isEqualToString:@"ACTIVE"])
    {
        MGSwipeButton *buttonZero = [MGSwipeButton buttonWithTitle:@"HOT" icon:nil backgroundColor:[UIColor colorWithRed:0.80 green:0.25 blue:0.15 alpha:1.0] padding:15 callback:^BOOL(MGSwipeTableCell *sender){
            NSIndexPath *path = [self.tableView indexPathForCell:sender];
            NSMutableArray *projectArray = [self.strAssemblyType isEqualToString:@"INACTIVE"] ? self.inactiveProjects : self.closedProjects;
            [self updateProjectStatusWithArray:projectArray andStatus:1 andIndexPath:path];
            return YES;
        }];
        [result addObject:buttonZero];
    }
    
    if(![self.strAssemblyType isEqualToString:@"INACTIVE"])
    {
        MGSwipeButton *buttonOne = [MGSwipeButton buttonWithTitle:@"COLD" icon:nil backgroundColor:[UIColor colorWithRed:0.62 green:0.77 blue:0.91 alpha:1.0] padding:15 callback:^BOOL(MGSwipeTableCell * sender){
            NSIndexPath *path = [self.tableView indexPathForCell:sender];
            NSMutableArray *projectArray = [self.strAssemblyType isEqualToString:@"ACTIVE"] ? self.activeProjects : self.closedProjects;
            [self updateProjectStatusWithArray:projectArray andStatus:2  andIndexPath:path];
            return YES;
        }];
        [result addObject:buttonOne];
    }
    
    if(![self.strAssemblyType isEqualToString:@"CLOSED"])
    {
        MGSwipeButton *buttonTwo = [MGSwipeButton buttonWithTitle:@"CLOSED" icon:nil backgroundColor:[UIColor colorWithRed:0.42 green:0.66 blue:0.31 alpha:1.0] padding:15 callback:^BOOL(MGSwipeTableCell * sender){
            NSIndexPath *path = [self.tableView indexPathForCell:sender];
            NSMutableArray *projectArray = [self.strAssemblyType isEqualToString:@"ACTIVE"] ? self.activeProjects : self.inactiveProjects;
            [self updateProjectStatusWithArray:projectArray andStatus:3  andIndexPath:path];
            return YES;
        }];
        [result addObject:buttonTwo];
    }
    
    return result;
}
//TableView Methods DONE*************************************************************************

- (void)updateProjectStatusWithArray:(NSMutableArray *)projectArray andStatus:(NSInteger)status andIndexPath:(NSIndexPath *)path
{
    NSDictionary *dic = [projectArray objectAtIndex:path.row];
    NSNumber *projectID = dic[@"project_ID"];
    NSString *myRequestString = [NSString stringWithFormat:@"userID=%@&projectID=%@&status=%ld", [UserInfoGlobal userID], projectID, (long)status];
    
    NSData *myRequestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
    NSString *URL = [NSString stringWithFormat:@"%@/iOS/Projects/updateProject.php", [UserInfoGlobal serverURL]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];
    [request setHTTPMethod: @"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody: myRequestData];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData * data,NSError * error)
     {
         if(!error)
         {
             NSDictionary *dicServerMessage = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
             
             //Update Success
             if([[dicServerMessage objectForKey:@"success"] isEqualToNumber:@1])
             {
                 [projectArray removeObjectAtIndex:path.row];
                 [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
                 [self loadProjects];
             }
             else
             {
                 UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"WARNING" message:[dicServerMessage objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                 [errorView show];
             }
         }
         else
         {
             UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"ERROR" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
             [errorView show];
         }
     }];
}

//Status Types
- (IBAction)btnActiveClicked:(id)sender
{
    self.strAssemblyType = @"ACTIVE";
    self.btnActive.tintColor = [UIColor darkGrayColor];
    self.btnInactive.tintColor = [[[[UIApplication sharedApplication] delegate] window] tintColor];
    self.btnClosed.tintColor = [[[[UIApplication sharedApplication] delegate] window] tintColor];
    
    [self.tableView reloadData];
}

- (IBAction)btnInactiveClicked:(id)sender
{
    self.strAssemblyType = @"INACTIVE";
    self.btnActive.tintColor = [[[[UIApplication sharedApplication] delegate] window] tintColor];
    self.btnInactive.tintColor = [UIColor darkGrayColor];
    self.btnClosed.tintColor = [[[[UIApplication sharedApplication] delegate] window] tintColor];
    
    [self.tableView reloadData];
}

- (IBAction)btnClosedClicked:(id)sender
{
    self.strAssemblyType = @"CLOSED";
    self.btnActive.tintColor = [[[[UIApplication sharedApplication] delegate] window] tintColor];
    self.btnInactive.tintColor = [[[[UIApplication sharedApplication] delegate] window] tintColor];
    self.btnClosed.tintColor = [UIColor darkGrayColor];
    
    [self.tableView reloadData];
}

- (IBAction)btnEmailClient:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    NSDictionary *dicProjectInfo;
    if([self.strAssemblyType isEqualToString:@"ACTIVE"])
    {
        dicProjectInfo = [self.activeProjects objectAtIndex:indexPath.row];
    }
    else if([self.strAssemblyType isEqualToString:@"INACTIVE"])
    {
        dicProjectInfo = [self.inactiveProjects objectAtIndex:indexPath.row];
    }
    else if([self.strAssemblyType isEqualToString:@"CLOSED"])
    {
        dicProjectInfo = [self.closedProjects objectAtIndex:indexPath.row];
    }
    //ERROR
    else
    {
        dicProjectInfo = nil;
    }
    
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    
    if(dicProjectInfo[@"contact_email"])
    {
        NSMutableArray *emailAddressesArray = [[NSMutableArray alloc] init];
        [emailAddressesArray addObject:dicProjectInfo[@"contact_email"]];
        [mailComposer setToRecipients:emailAddressesArray];
    }
    
    [mailComposer setSubject:self.dicEmailClient[@"emailSubject"]];
    
    NSArray* arrayName = [dicProjectInfo[@"contact_name"] componentsSeparatedByString: @" "];
    NSMutableString *strFirstName = [[NSMutableString alloc] initWithString:arrayName[0]];
    if(![strFirstName isEqualToString:@""])
        [strFirstName appendString:@",\n\n"];
    
    NSString *strBody = [NSString stringWithFormat:@"%@ %@ %@/home/#/client/%@ %@ %@\n%@\n%@", strFirstName, self.dicEmailClient[@"emailBeforeLink"], [UserInfoGlobal serverURL], dicProjectInfo[@"project_ID"], self.dicEmailClient[@"emailAfterLink"], self.dicEmailClient[@"nameSalesPerson"] ,self.dicEmailClient[@"emailSalesPerson"], self.dicEmailClient[@"phoneSalesPerson"]];
    [mailComposer setMessageBody:strBody isHTML:NO];
    //Opens the view for sending an email
    [self presentViewController:mailComposer animated:YES completion:nil];
}

//After users sends the email or cancels, the view will return to the SingleEventView
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self disablesAutomaticKeyboardDismissal];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"NewProjectToMapNew"])
    {
        Map *vc = segue.destinationViewController;
        vc.isNewProject = YES;
    }
    else
    {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        
        NSDictionary *dicProjectInfo;
        if([self.strAssemblyType isEqualToString:@"ACTIVE"])
        {
            dicProjectInfo = [self.activeProjects objectAtIndex:indexPath.row];
        }
        else if([self.strAssemblyType isEqualToString:@"INACTIVE"])
        {
            dicProjectInfo = [self.inactiveProjects objectAtIndex:indexPath.row];
        }
        else if([self.strAssemblyType isEqualToString:@"CLOSED"])
        {
            dicProjectInfo = [self.closedProjects objectAtIndex:indexPath.row];
        }
        
        if([segue.identifier isEqualToString:@"ExistingProjectToMapNew"])
        {
            Map *vc = segue.destinationViewController;
            vc.isNewProject = NO;
            vc.strProjectID = [NSString stringWithFormat:@"%f", [[dicProjectInfo objectForKey:@"project_ID"] doubleValue]];
            vc.strNavBarTitle = [dicProjectInfo objectForKey:@"project_name"];
            vc.strCostPerKWH = [NSString stringWithFormat:@"%d", [[dicProjectInfo objectForKey:@"power_cost_per_kWh"]intValue]];
            vc.strDateOfService = [NSString stringWithFormat:@"%d", [[dicProjectInfo objectForKey:@"date_of_service"]intValue]];
            if([vc.strDateOfService isEqualToString:@"0"])
            {
                vc.strDateOfService = @"";
            }
            vc.strNameOfRep = [dicProjectInfo objectForKey:@"contact_name"];
            vc.strPhone = [dicProjectInfo objectForKey:@"contact_phone"];
            vc.strEmail = [dicProjectInfo objectForKey:@"contact_email"];
            vc.strComments = [dicProjectInfo objectForKey:@"comments"];
            vc.strDailyUsageHours = [NSString stringWithFormat:@"%d", [[dicProjectInfo objectForKey:@"project_usage_hours"] intValue]];
        }
        else if([segue.identifier isEqualToString:@"ProjectsToPresentation"])
        {
            Presentation *vc = segue.destinationViewController;
            vc.strProjectID = [NSString stringWithFormat:@"%f", [[dicProjectInfo objectForKey:@"project_ID"] doubleValue]];;
            vc.strProjectTitle = [dicProjectInfo objectForKey:@"project_name"];
        }
    }
}
@end
