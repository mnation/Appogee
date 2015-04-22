//
//  MarkerInfoDelegate.m
//  ArkonLED
//
//  Created by Michael Nation on 9/9/14.
//  Copyright (c) 2014 ArkonLED. All rights reserved.
//

#import "MarkerInfoDelegate.h"

@interface MarkerInfoDelegate ()

@end

@implementation MarkerInfoDelegate

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
    
    self.updatePhoto = NO;
    self.txtNumOfHeads.text = @"";
    self.txtWattage.text = @"";
    self.txtPoleHeight.text = @"";
    self.txtNumOfHeadsProposed.text = @"";
    
    self.hideSectionsWithHiddenRows = YES;
    
    self.bulbNamesData = [[BulbNamesData alloc] init];
    self.ledFixturesData = [[LEDFixturesData alloc] init];
    
    //Change Content Mode for image button
    self.btnImage.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.btnImage.imageView setClipsToBounds:YES];
    
    if([self isNewMarker])
    {
        //Hide Delete button
        [self cell:self.cellDeleteMarker setHidden:YES];
        
        //Hide PrePopulate Switch if previous marker doesn't exist
        if(self.markerPrevious == NULL)
            [self cell:self.cellPrepopulate setHidden:YES];
    }
    else
        [self loadExistingMarkerDetails];
    
    [self loadBulbTypesForPickerView];
    [self loadLEDFixturesForPickerView];
    
    //Hides cells that are set to Hidden
    [self reloadDataAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    if([self isNewMarker])
        //Set color to red for Shoebox. nil set's icon color to default
        self.marker.icon = nil;
}

- (void)loadExistingMarkerDetails
{
    //Hide Cancel Button and Hide Prepopulate-Switch
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = nil;
    [self cell:self.cellPrepopulate setHidden:YES];
    
    self.dicMarkerGlobal = self.marker.userData;
    [self.segContAssemblyType setSelectedSegmentIndex:[[self.dicMarkerGlobal objectForKey:@"assemblyTypeID"] integerValue]];
    [self assemblyTypeChanged:self];
    
    [self.switchPoleExist setOn:[[self.dicMarkerGlobal objectForKey:@"poleExist"] boolValue] animated:NO];
    if(!self.switchPoleExist.isOn)
        [self poleExistSwitchChanged:self];
    self.txtNumOfHeads.text = [self.dicMarkerGlobal objectForKey:@"numOfHeads"];
    self.txtWattage.text = [self.dicMarkerGlobal objectForKey:@"wattage"];
    [self.switchOneToOne setOn:[[self.dicMarkerGlobal objectForKey:@"oneToOneReplace"] boolValue] animated:NO];
    if(!self.switchOneToOne.isOn)
        [self oneToOneSwitchChanged:self];
    self.txtNumOfHeadsProposed.text = [self.dicMarkerGlobal objectForKey:@"numOfHeadsProposed"];
    [self.switchBracket setOn:[[self.dicMarkerGlobal objectForKey:@"bracket"] boolValue] animated:NO];
    self.txtPoleHeight.text = [self.dicMarkerGlobal objectForKey:@"height"];
    
    if([[self.dicMarkerGlobal objectForKey:@"hasPicture"] isEqualToString:@"1"])
        [self loadPoleImageWithPoleID:[[self.dicMarkerGlobal objectForKey:@"poleID"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    else
        self.btnImage.imageView.image = nil;
}

- (void)loadBulbTypesForPickerView //Legacy Fixtures
{
    [self.bulbNamesData loadBulbTypes:^(BOOL success)
    {
        if(success)
        {
            if([self isNewMarker])
            {
                self.strSelectedBulbID = [self.bulbNamesData bulbTypeIDAtIndex:0];
                self.strSelectedBulbType = [self.bulbNamesData bulbTypeDescriptionAtIndex:0];
                
                [self.pickerBulbType reloadAllComponents];
            }
            else
            {
                self.strSelectedBulbID = [self.dicMarkerGlobal objectForKey:@"bulbTypeID"];
                self.strSelectedBulbType = [self.dicMarkerGlobal objectForKey:@"bulbTypeName"];
                
                [self.pickerBulbType reloadAllComponents];
                
                NSUInteger bulbTypeIndex = [self.bulbNamesData bulbTypeIndexWithID:self.strSelectedBulbID];
                if(bulbTypeIndex != NSNotFound)
                    [self.pickerBulbType selectRow:bulbTypeIndex inComponent:0 animated:NO];
            }
        }
    }];
}

- (void)loadLEDFixturesForPickerView //proposed
{
    [self.ledFixturesData loadLEDFixtures:^(BOOL success)
    {
        if(success)
        {
            if([self isNewMarker])
            {
                self.strSelectedLEDFixtureID = [self.ledFixturesData shoeBoxIDAtIndex:0];
                [self.pickerLEDFixtures reloadAllComponents];
            }
            else
            {
                self.strSelectedLEDFixtureID = [self.dicMarkerGlobal objectForKey:@"LEDFixtureID"];
                
                if([self lEDFixturesPickerIsShoeBox])
                {
                    [self.pickerLEDFixtures reloadAllComponents];
                    
                    NSUInteger shoeBoxIndex = [self.ledFixturesData shoeBoxIndexWithID:self.strSelectedLEDFixtureID];
                    if(shoeBoxIndex != NSNotFound)
                        [self.pickerLEDFixtures selectRow:shoeBoxIndex inComponent:0 animated:NO];
                }
                else
                {
                    [self.pickerLEDFixtures reloadAllComponents];
                    
                    NSUInteger wallPackIndex = [self.ledFixturesData wallPackIndexWithID:self.strSelectedLEDFixtureID];
                    if(wallPackIndex != NSNotFound)
                        [self.pickerLEDFixtures selectRow:wallPackIndex inComponent:0 animated:NO];
                }
            }
        }
    }];
}

- (void)loadPoleImageWithPoleID:(NSString *)poleID
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd_HH:MM:SS"];
    NSString* strDate = [formatter stringFromDate:[NSDate date]];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/iOS/Images/%@.jpg?x=%@", [UserInfoGlobal serverURL], poleID, strDate]];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData * data,NSError * error)
     {
         if(!error)
             [self.btnImage setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
         else
         {
             UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"ERROR" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
             [errorView show];
         }
     }];
}

- (IBAction)doneBtnClicked:(id)sender
{
    if(![self inputFieldsAreValid])
        return;
    
    NSMutableDictionary *dicMarker;
    BOOL newMarkerFlag = NO;
    
    NSString *strHasPicture = @"1";
    if(self.btnImage.imageView.image == nil)
        strHasPicture = @"0";

    if([self isNewMarker])
    {
        dicMarker = [[NSMutableDictionary alloc] init];
        newMarkerFlag = YES;
        dicMarker[@"markerNum"] = self.markerCount;
        
        if([strHasPicture isEqualToString:@"1"])
            dicMarker[@"pictureData"] = UIImageJPEGRepresentation(self.btnImage.imageView.image, 0);
    }
    else //Update Database
    {
        dicMarker = self.marker.userData;
        
        NSString *strPoleHeight;
        if([self.txtPoleHeight.text isEqualToString:@""])
            strPoleHeight = @"0";
        else
            strPoleHeight = self.txtPoleHeight.text;
        
        if(self.updatePhoto)
        {
            if(self.btnImage.imageView.image != nil)
                [self uploadImage:UIImageJPEGRepresentation(self.btnImage.imageView.image, 0) filename:dicMarker[@"poleID"]];
            //Delete image if image is nil and a picture in DB currently exist
            else if(self.btnImage.imageView.image == nil && [dicMarker[@"hasPicture"] isEqualToString:@"1"])
            {
                NSString *myRequestString = [NSString stringWithFormat:@"poleID=%@", dicMarker[@"poleID"]];
                
                // Create Data from request
                NSData *myRequestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
                NSString *URL = [NSString stringWithFormat:@"%@/iOS/LightPoles/deletePicture.php", [UserInfoGlobal serverURL]];
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];
                [request setHTTPMethod: @"POST"];
                [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
                [request setHTTPBody: myRequestData];
                [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData * data,NSError * error)
                 {
                     //Delete Failed
                     if(error)
                     {
                         UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"ERROR" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                         [errorView show];
                     }
                 }];
            }
        }
        
        NSString *myRequestString = [NSString stringWithFormat:@"poleID=%@&poleExist=%@&numHeads=%@&bulbID=%@&assemblyTypeID=%@&legacyWattage=%@&hasPicture=%@&oneToOneReplace=%@&numHeadsProposed=%@&poleHeight=%@&ledFixtureID=%@&bracket=%@&userID=%@", dicMarker[@"poleID"], @(self.switchPoleExist.isOn), self.txtNumOfHeads.text, self.strSelectedBulbID, @(self.segContAssemblyType.selectedSegmentIndex), self.txtWattage.text, strHasPicture, @(self.switchOneToOne.isOn), self.txtNumOfHeadsProposed.text, strPoleHeight, self.strSelectedLEDFixtureID, @(self.switchBracket.isOn), [UserInfoGlobal userID]];

        NSData *myRequestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
        NSString *URL = [NSString stringWithFormat:@"%@/iOS/LightPoles/updatePole.php", [UserInfoGlobal serverURL]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];
        [request setHTTPMethod: @"POST"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [request setHTTPBody: myRequestData];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData * data,NSError * error)
         {
             if(!error)
             {
                 NSDictionary *dicServerMessage = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                 
                 //Update Failed
                 if([[dicServerMessage objectForKey:@"success"] isEqualToNumber:@0])
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
    
    dicMarker[@"poleExist"] = @(self.switchPoleExist.isOn);
    dicMarker[@"numOfHeads"] = self.txtNumOfHeads.text;
    dicMarker[@"bulbTypeName"] = self.strSelectedBulbType;
    dicMarker[@"bulbTypeID"] = self.strSelectedBulbID;
    dicMarker[@"assemblyTypeID"] = @(self.segContAssemblyType.selectedSegmentIndex);
    dicMarker[@"wattage"] = self.txtWattage.text;
    dicMarker[@"oneToOneReplace"] = @(self.switchOneToOne.isOn);
    dicMarker[@"numOfHeadsProposed"] = self.txtNumOfHeadsProposed.text;
    dicMarker[@"LEDFixtureID"] = self.strSelectedLEDFixtureID;
    dicMarker[@"bracket"] = @(self.switchBracket.isOn);
    dicMarker[@"height"] = self.txtPoleHeight.text;
    dicMarker[@"hasPicture"] = strHasPicture;
    
    self.marker.userData = dicMarker;
    self.marker.title = [NSString stringWithFormat:@"#%@", dicMarker[@"markerNum"]];
    self.marker.snippet = @"";
    //Current
    if(self.switchPoleExist.isOn)
    {
        if([self.txtNumOfHeads.text intValue] == 1)
        {
            if([self lEDFixturesPickerIsShoeBox])
                self.marker.snippet = [NSString stringWithFormat:@"C: %@ Shoebox, %@W %@\n", self.txtNumOfHeads.text, self.txtWattage.text, self.strSelectedBulbType];
            else
                self.marker.snippet = [NSString stringWithFormat:@"C: %@ Wallpack/Canopy, %@W %@\n", self.txtNumOfHeads.text, self.txtWattage.text, self.strSelectedBulbType];
        }
        else
        {
            if([self lEDFixturesPickerIsShoeBox])
                self.marker.snippet = [NSString stringWithFormat:@"C: %@ Shoeboxes, %@W %@\n", self.txtNumOfHeads.text, self.txtWattage.text, self.strSelectedBulbType];
            else
                self.marker.snippet = [NSString stringWithFormat:@"C: %@ Wallpacks/Canopies, %@W %@\n", self.txtNumOfHeads.text, self.txtWattage.text, self.strSelectedBulbType];
        }
    }
    
    //Proposed
    if(self.switchOneToOne.isOn)
    {
        NSString *strLEDFixtureWattage = @"0";
        if([self lEDFixturesPickerIsShoeBox])
        {
            NSUInteger shoeBoxIndex = [self.ledFixturesData shoeBoxIndexWithID:self.strSelectedLEDFixtureID];
            if(shoeBoxIndex != NSNotFound)
                strLEDFixtureWattage = [self.ledFixturesData shoeBoxWattageAtIndex:shoeBoxIndex];
        }
        else
        {
            NSUInteger wallPackIndex = [self.ledFixturesData wallPackIndexWithID:self.strSelectedLEDFixtureID];
            if(wallPackIndex != NSNotFound)
                strLEDFixtureWattage = [self.ledFixturesData wallPackWattageAtIndex:wallPackIndex];
        }

        if([self.txtNumOfHeadsProposed.text intValue] == 1)
        {
            if([self lEDFixturesPickerIsShoeBox])
                self.marker.snippet = [NSString stringWithFormat:@"%@P: %@ Shoebox, %@W LED", self.marker.snippet, self.txtNumOfHeadsProposed.text, strLEDFixtureWattage];
            else
                self.marker.snippet = [NSString stringWithFormat:@"%@P: %@ Wallpack/Canopy, %@W LED", self.marker.snippet, self.txtNumOfHeadsProposed.text, strLEDFixtureWattage];
        }
        else
        {
            if([self lEDFixturesPickerIsShoeBox])
                self.marker.snippet = [NSString stringWithFormat:@"%@P: %@ Shoeboxes, %@W LED", self.marker.snippet, self.txtNumOfHeadsProposed.text, strLEDFixtureWattage];
            else
                self.marker.snippet = [NSString stringWithFormat:@"%@P: %@ Wallpacks/Canopies, %@W LED", self.marker.snippet, self.txtNumOfHeadsProposed.text, strLEDFixtureWattage];
        }
    }
    
    //Return to Map
    [self.delegate doneMarkerInfo:self.marker isNewMarker:newMarkerFlag];
}

- (BOOL)inputFieldsAreValid
{
    if(self.switchPoleExist.isOn && [self.txtNumOfHeads.text isEqualToString:@""])
    {
        UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"WARNING" message:@"Enter Number of Heads for Current Light Pole." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [errorView show];
        
        return NO;
    }
    
    if(self.switchPoleExist.isOn && [self.txtWattage.text isEqualToString:@""])
    {
        UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"WARNING" message:@"Enter Wattage for Current Light Pole." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [errorView show];
        
        return NO;
    }
    
    if(self.switchOneToOne.isOn && [self.txtNumOfHeadsProposed.text isEqualToString:@""])
    {
        UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"WARNING" message:@"Enter Number of Heads for Proposed Light Pole." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [errorView show];
        
        return NO;
    }
    
    return YES;
}

- (IBAction)cancelBtnClicked:(id)sender
{
    self.marker.userData = NULL;
    [self.delegate doneMarkerInfo:self.marker isNewMarker:YES];
}

- (IBAction)deleteBtnClicked:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CONFIRM" message:[NSString stringWithFormat:@"Are you sure you want to delete this light pole?"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Delete was clicked
    if(buttonIndex == 1)
    {
        NSDictionary *dicMarker = self.marker.userData;
        
        NSString *myRequestString = [NSString stringWithFormat:@"poleID=%@&hasPicture=%@&userID=%@", dicMarker[@"poleID"], dicMarker[@"hasPicture"],[UserInfoGlobal userID]];

        NSData *myRequestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
        NSString *URL = [NSString stringWithFormat:@"%@/iOS/LightPoles/deletePole.php", [UserInfoGlobal serverURL]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [request setHTTPBody: myRequestData];
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
             }
             else
             {
                 UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"ERROR" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                 [errorView show];
             }
         }];
        
        self.marker.userData = NULL;
        [self.delegate doneMarkerInfo:self.marker isNewMarker:NO];
    }
}

- (IBAction)numOfHeadsCurrentChanged:(id)sender
{
    if(![self.txtNumOfHeads.text isEqualToString:@""])
        self.txtNumOfHeadsProposed.text = self.txtNumOfHeads.text;
}


- (IBAction)assemblyTypeChanged:(id)sender
{
    if([self lEDFixturesPickerIsShoeBox])
    {
        //Default to first item when assembly type changes
        self.strSelectedLEDFixtureID = [self.ledFixturesData shoeBoxIDAtIndex:0];
        
        //Change marker color to red
        self.marker.icon = nil;
    }
    else
    {
        //Default to first item when assembly type changes
        self.strSelectedLEDFixtureID = [self.ledFixturesData wallPackIDAtIndex:0];
        
        //Set Number of Heads to 1
        self.txtNumOfHeads.text = @"1";
        self.txtNumOfHeadsProposed.text = @"1";
        
        //Change marker color to blue
        self.marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
    }
    
    [self.pickerLEDFixtures reloadAllComponents];
    [self.pickerLEDFixtures selectRow:0 inComponent:0 animated:NO];
}


- (IBAction)prepopulateSwitchChanged:(id)sender
{
    if(self.switchPrepopulate.isOn)
    {
        NSDictionary *dicPreviousMarker = self.markerPrevious.userData;
        self.segContAssemblyType.selectedSegmentIndex = [dicPreviousMarker[@"assemblyTypeID"] longValue];
        [self assemblyTypeChanged:self];
        
        [self.switchPoleExist setOn:[[dicPreviousMarker objectForKey:@"poleExist"] boolValue] animated:NO];
        [self poleExistSwitchChanged:self];
        
        self.txtNumOfHeads.text = [dicPreviousMarker objectForKey:@"numOfHeads"];
        self.txtWattage.text = [dicPreviousMarker objectForKey:@"wattage"];
        
        self.strSelectedBulbID = [dicPreviousMarker objectForKey:@"bulbTypeID"];
        self.strSelectedBulbType = [dicPreviousMarker objectForKey:@"bulbTypeName"];
        [self.pickerBulbType reloadAllComponents];
        NSUInteger bulbTypeIndex = [self.bulbNamesData bulbTypeIndexWithID:self.strSelectedBulbID];
        if(bulbTypeIndex != NSNotFound)
            [self.pickerBulbType selectRow:bulbTypeIndex inComponent:0 animated:NO];
        
        self.strSelectedLEDFixtureID = [dicPreviousMarker objectForKey:@"LEDFixtureID"];
        [self.pickerLEDFixtures reloadAllComponents];
        if([self lEDFixturesPickerIsShoeBox])
        {
            NSUInteger shoeBoxIndex = [self.ledFixturesData shoeBoxIndexWithID:self.strSelectedLEDFixtureID];
            if(shoeBoxIndex != NSNotFound)
                [self.pickerLEDFixtures selectRow:shoeBoxIndex inComponent:0 animated:NO];
        }
        else
        {
            NSUInteger wallPackIndex = [self.ledFixturesData wallPackIndexWithID:self.strSelectedLEDFixtureID];
            if(wallPackIndex != NSNotFound)
                [self.pickerLEDFixtures selectRow:wallPackIndex inComponent:0 animated:NO];
        }
        
        [self.switchOneToOne setOn:[[dicPreviousMarker objectForKey:@"oneToOneReplace"] boolValue] animated:NO];
        [self oneToOneSwitchChanged:self];
        
        self.txtNumOfHeadsProposed.text = [dicPreviousMarker objectForKey:@"numOfHeadsProposed"];
        
        [self.switchBracket setOn:[[dicPreviousMarker objectForKey:@"bracket"] boolValue] animated:NO];
        self.txtPoleHeight.text = [dicPreviousMarker objectForKey:@"height"];
        
        if([[dicPreviousMarker objectForKey:@"hasPicture"] isEqualToString:@"1"])
            [self loadPoleImageWithPoleID:[dicPreviousMarker objectForKey:@"poleID"]];
        else
            self.btnImage.imageView.image = nil;
    }
}

- (IBAction)poleExistSwitchChanged:(id)sender
{
    if(self.switchPoleExist.isOn)
    {
        [self cell:self.cellNumOfHeads setHidden:NO];
        [self cell:self.cellWattage setHidden:NO];
        [self cell:self.cellBulbTypes setHidden:NO];
    }
    else
    {
        [self cell:self.cellNumOfHeads setHidden:YES];
        [self cell:self.cellWattage setHidden:YES];
        [self cell:self.cellBulbTypes setHidden:YES];
    }
    
    //Hides data selected datacells
    [self reloadDataAnimated:YES];
}


- (IBAction)oneToOneSwitchChanged:(id)sender
{
    if(self.switchOneToOne.isOn)
    {
        [self cell:self.cellNumOfHeadsProposed setHidden:NO];
        [self cell:self.cellModalTypes setHidden:NO];
        [self cell:self.cellBracket setHidden:NO];
        [self cell:self.cellPoleHeight setHidden:NO];
        [self cell:self.cellImage setHidden:NO];
    }
    else
    {
        [self cell:self.cellNumOfHeadsProposed setHidden:YES];
        [self cell:self.cellModalTypes setHidden:YES];
        [self cell:self.cellBracket setHidden:YES];
        [self cell:self.cellPoleHeight setHidden:YES];
        [self cell:self.cellImage setHidden:YES];
    }
    
    //Hides data selected datacells
    [self reloadDataAnimated:YES];
}


- (IBAction)choosePhotoBtnClicked:(id)sender
{
    self.updatePhoto = YES;
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    
    [self.btnImage setImage:image forState:UIControlStateNormal];
    
    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)removeImageBtnClicked:(id)sender
{
    self.updatePhoto = YES;
    self.btnImage.imageView.image = nil;
}

- (void)uploadImage:(NSData *)imageData filename:(NSString *)filename
{
    NSString *URL = [NSString stringWithFormat:@"%@/iOS/LightPoles/uploadPicture.php", [UserInfoGlobal serverURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:URL]];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\n",filename]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imageData]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
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
         }
         else
         {
             UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"ERROR" message:[NSString stringWithFormat:@"%@ Image of light pole may not have been saved.", [error localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
             [errorView show];
         }
     }];
}

- (IBAction)btnImageClicked:(id)sender
{
    if(self.btnImage.imageView.image != nil)
        [self performSegueWithIdentifier:@"ToLargeImage" sender:self];
}

- (BOOL)lEDFixturesPickerIsShoeBox
{
    return self.segContAssemblyType.selectedSegmentIndex == 0;
}

- (BOOL)isNewMarker
{
    return self.marker.userData == NULL;
}

//PickerView Delegate Methods*********************************************************
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(pickerView.tag == 0)
    {
        self.strSelectedBulbType = [self.bulbNamesData bulbTypeDescriptionAtIndex:row];
        self.strSelectedBulbID = [self.bulbNamesData bulbTypeIDAtIndex:row];
    }
    else
    {
        if(self.segContAssemblyType.selectedSegmentIndex == 0)
            self.strSelectedLEDFixtureID = [self.ledFixturesData shoeBoxIDAtIndex:row];
        else
            self.strSelectedLEDFixtureID = [self.ledFixturesData wallPackIDAtIndex:row];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(pickerView.tag == 0)
        return [self.bulbNamesData bulbTypesCount];
    else
    {
        if(self.segContAssemblyType.selectedSegmentIndex == 0)
            return [self.ledFixturesData shoeBoxesCount];
        else
            return [self.ledFixturesData wallPacksCount];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(pickerView.tag == 0)
        return [self.bulbNamesData bulbTypeDescriptionAtIndex:row];
    else
    {
        if([self lEDFixturesPickerIsShoeBox])
            return [self.ledFixturesData shoeBoxDescriptionAtIndex:row];
        else
            return [self.ledFixturesData wallPackDescriptionAtIndex:row];
    }
}

- (IBAction)dismissKeyboard:(id)sender
{
    [self.view endEditing:YES];
}

//Tableview Delegate Methods **********************************************************
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 8, 0, 0)];
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 8, 0, 0)];
}

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)])
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 8, 0, 0)];
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0, 8, 0, 0)];
}
//Tableview Delegate Methods DONE ******************************************************


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ToLargeImage"])
    {
        LightPoleLargeImage *vc = segue.destinationViewController;
        vc.imgLightPole = self.btnImage.imageView.image;
    }
}
@end
