//
//  MarkerInfoDelegate.h
//  ArkonLED
//
//  Created by Michael Nation on 9/9/14.
//  Copyright (c) 2014 ArkonLED. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "StaticDataTableViewController.h"
#import "UserInfoGlobal.h"
#import "NSData+Base64.h"
#import "LightPoleLargeImage.h"
#import "BulbNamesData.h"
#import "LEDFixturesData.h"

@protocol MarkerInfoDelegate <NSObject>

-(void)doneMarkerInfo:(GMSMarker *)marker isNewMarker:(BOOL)isNewMarker;

@end

@interface MarkerInfoDelegate : StaticDataTableViewController <UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property(strong, nonatomic) id <MarkerInfoDelegate> delegate;

@property (nonatomic) bool updatePhoto;
@property (strong, nonatomic) GMSMarker *marker;
@property (strong, nonatomic) GMSMarker *markerPrevious;
@property (strong, nonatomic) NSNumber *markerCount;
@property (strong, nonatomic) NSDictionary *dicMarkerGlobal;
@property (strong, nonatomic) BulbNamesData *bulbNamesData;
@property (strong, nonatomic) LEDFixturesData *ledFixturesData;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnCancel;

@property (strong, nonatomic) IBOutlet UISwitch *switchPrepopulate;

//Current
@property (strong, nonatomic) IBOutlet UISwitch *switchPoleExist;
@property (strong, nonatomic) IBOutlet UITextField *txtNumOfHeads;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellNumOfHeads;
@property (strong, nonatomic) IBOutlet UITextField *txtWattage;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellWattage;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerBulbType;
@property (strong, nonatomic) NSString *strSelectedBulbType;
@property (strong, nonatomic) NSString *strSelectedBulbID;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellBulbTypes;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segContAssemblyType;


//Proposed
@property (strong, nonatomic) IBOutlet UISwitch *switchOneToOne;
@property (strong, nonatomic) IBOutlet UITextField *txtNumOfHeadsProposed;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellNumOfHeadsProposed;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerLEDFixtures;
@property (strong, nonatomic) NSString *strSelectedLEDFixtureID;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellModalTypes;
@property (strong, nonatomic) IBOutlet UISwitch *switchBracket;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellBracket;
@property (strong, nonatomic) IBOutlet UITextField *txtPoleHeight;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellPoleHeight;
@property (strong, nonatomic) IBOutlet UIButton *btnRemoveImage;
@property (strong, nonatomic) IBOutlet UIButton *btnImage;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellImage;

//Cells
@property (strong, nonatomic) IBOutlet UITableViewCell *cellPrepopulate;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellDeleteMarker;


@end
