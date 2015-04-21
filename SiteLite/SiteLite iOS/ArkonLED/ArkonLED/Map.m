//
//  Map.m
//  ArkonLED
//
//  Created by Michael Nation on 9/8/14.
//  Copyright (c) 2014 ArkonLED. All rights reserved.
//

#import "Map.h"

@interface Map ()

@end

@implementation Map

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{

    [super viewDidLoad];
    
    self.navigationController.toolbarHidden = YES;
    
    self.arrayMarkers = [[NSMutableArray alloc] init];
    self.markerCount = 0;
    self.markerWindowIsOpen = NO;
    
    [self loadMapView];
    
    if(self.isNewProject)
        [self startLocationManager];
    else
        [self loadExistingProjectDetails];
}

- (void)viewWillAppear:(BOOL)animated
{
    if(self.isNewProject)
        [self performSegueWithIdentifier:@"MapToMapDetails" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)loadMapView
{
    self.mapView_ = [[GMSMapView alloc] initWithFrame:self.view.bounds];
    self.mapView_.myLocationEnabled = YES;
    self.mapView_.delegate = self;
    self.mapView_.mapType = kGMSTypeHybrid;
    [self.mapView_ setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    self.mapView_.hidden = YES;
    [self.view insertSubview:self.mapView_ atIndex:0];
}

- (void)startLocationManager
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];
    }
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self.locationManager stopUpdatingLocation];
    
    if(self.locationManager.location)
    {
        self.latitudeCurrentLocation = self.locationManager.location.coordinate.latitude;
        self.longitudeCurrentLocation = self.locationManager.location.coordinate.longitude;
        
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude zoom:18];
        self.mapView_.camera = camera;
        self.mapView_.hidden = NO;
        self.activityIndicator.hidden = YES;
    }
    else
    {
        UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Failed to get your current location." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [errorView show];
    }
    
}

- (void)loadExistingProjectDetails
{
    self.navigationItem.title = self.strNavBarTitle;
    [UserInfoGlobal userID];
    //Get Light Pole Markers
    NSString *strURL = [NSString stringWithFormat:@"%@/iOS/LightPoles/getPoles.php?userID=%@&projectID=%@", [UserInfoGlobal serverURL], [UserInfoGlobal userID], self.strProjectID];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:strURL]];
    [request setHTTPMethod: @"GET"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData * data,NSError * error)
     {
         if(!error)
         {
             NSDictionary *dicServerMessage = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
             
             //Successful
             if([[dicServerMessage objectForKey:@"success"] isEqualToNumber:@1])
             {
                 self.arrayResponse = [dicServerMessage objectForKey:@"message"];
                 
                 if(self.arrayResponse.count > 0)
                 {
                     int i;
                     NSDictionary *dicPole;
                     self.path = [GMSMutablePath path];
                     for(i = 0; i < self.arrayResponse.count; i++)
                     {
                         dicPole = [self.arrayResponse objectAtIndex:i];
                         
                         //Add Coordinates to path
                         [self.path addCoordinate:CLLocationCoordinate2DMake([[dicPole objectForKey:@"poleLat"] doubleValue], [[dicPole objectForKey:@"poleLong"] doubleValue])];
                         
                         // Create a marker
                         GMSMarker *marker = [[GMSMarker alloc] init];
                         marker.position = CLLocationCoordinate2DMake([[dicPole objectForKey:@"poleLat"] doubleValue], [[dicPole objectForKey:@"poleLong"] doubleValue]);
                         marker.draggable = YES;
                         marker.map = self.mapView_;
                         
                         NSMutableDictionary *dicMarker = [[NSMutableDictionary alloc] init];
                         dicMarker[@"poleID"] = [NSString stringWithFormat:@"%@", [dicPole objectForKey:@"poleID"]];
                         dicMarker[@"poleExist"] = [dicPole objectForKey:@"poleExist"];
                         dicMarker[@"numOfHeads"] = [NSString stringWithFormat:@"%@", [dicPole objectForKey:@"numOfHeads"]];
                         dicMarker[@"bulbTypeName"] = [dicPole objectForKey:@"bulbDesc"];
                         dicMarker[@"bulbTypeID"] = [NSString stringWithFormat:@"%@", [dicPole objectForKey:@"bulbID"]];
                         dicMarker[@"assemblyTypeID"] = [dicPole objectForKey:@"assemblyTypeID"];
                         dicMarker[@"wattage"] = [NSString stringWithFormat:@"%@", [dicPole objectForKey:@"legWattage"]];
                         dicMarker[@"oneToOneReplace"] = [dicPole objectForKey:@"oneToOne"];
                         dicMarker[@"numOfHeadsProposed"] = [NSString stringWithFormat:@"%@", [dicPole objectForKey:@"numOfHeadsProposed"]];
                         dicMarker[@"LEDFixtureID"] = [NSString stringWithFormat:@"%@", [dicPole objectForKey:@"LEDfixtureID"]];
                         dicMarker[@"bracket"] = [dicPole objectForKey:@"bracket"];
                         dicMarker[@"height"] = [NSString stringWithFormat:@"%@", [dicPole objectForKey:@"poleHeight"]];
                         dicMarker[@"markerNum"] = [dicPole objectForKey:@"markerNum"];
                         dicMarker[@"hasPicture"] = [NSString stringWithFormat:@"%@", [dicPole objectForKey:@"hasPicture"]];
                         
                         marker.userData = dicMarker;
                         marker.title = [NSString stringWithFormat:@"#%@", [dicPole objectForKey:@"markerNum"]];
                         marker.snippet = @"";
                         //Current
                         if([[dicPole objectForKey:@"poleExist"] intValue] == 1)
                         {
                             if([dicMarker[@"numOfHeads"] intValue] == 1)
                             {
                                 //Shoebox
                                 if([dicMarker[@"assemblyTypeID"] intValue] == 0)
                                     marker.snippet = [NSString stringWithFormat:@"C: %@ Shoebox, %@W %@\n", dicMarker[@"numOfHeads"], dicMarker[@"wattage"], dicMarker[@"bulbTypeName"]];
                                 //Wallpack
                                 else
                                     marker.snippet = [NSString stringWithFormat:@"C: %@ Wallpack/Canopy, %@W %@\n", dicMarker[@"numOfHeads"], dicMarker[@"wattage"], dicMarker[@"bulbTypeName"]];
                             }
                             else
                             {
                                 //Shoebox
                                 if([dicMarker[@"assemblyTypeID"] intValue] == 0)
                                     marker.snippet = [NSString stringWithFormat:@"C: %@ Shoeboxes, %@W %@\n", dicMarker[@"numOfHeads"], dicMarker[@"wattage"], dicMarker[@"bulbTypeName"]];
                                 //Wallpack
                                 else
                                     marker.snippet = [NSString stringWithFormat:@"C: %@ Wallpacks/Canopies, %@W %@\n", dicMarker[@"numOfHeads"], dicMarker[@"wattage"], dicMarker[@"bulbTypeName"]];
                             }
                         }
                         
                         //Proposed
                         if([dicMarker[@"oneToOneReplace"] intValue] == 1)
                         {
                             //Find index of LED Fixture. Get Wattage
                             NSString *strLEDFixtureWattage = [dicPole objectForKey:@"LEDwattage"];;
                             
                             if([dicMarker[@"numOfHeadsProposed"] intValue] == 1)
                             {
                                 //Shoebox
                                 if([dicMarker[@"assemblyTypeID"] intValue] == 0)
                                     marker.snippet = [NSString stringWithFormat:@"%@P: %@ Shoebox, %@W LED", marker.snippet, dicMarker[@"numOfHeadsProposed"], strLEDFixtureWattage];
                                 //Wallpack
                                 else
                                     marker.snippet = [NSString stringWithFormat:@"%@P: %@ Wallpack/Canopy, %@W LED", marker.snippet, dicMarker[@"numOfHeadsProposed"], strLEDFixtureWattage];
                             }
                             else
                             {
                                 //Shoebox
                                 if([dicMarker[@"assemblyTypeID"] intValue] == 0)
                                     marker.snippet = [NSString stringWithFormat:@"%@P: %@ Shoeboxes, %@W LED", marker.snippet, dicMarker[@"numOfHeadsProposed"], strLEDFixtureWattage];
                                 //Wallpack
                                 else
                                     marker.snippet = [NSString stringWithFormat:@"%@P: %@ Wallpacks/Canopies, %@W LED", marker.snippet, dicMarker[@"numOfHeadsProposed"], strLEDFixtureWattage];
                             }
                         }
                         
                         [self.arrayMarkers addObject:marker];
                     }
                     
                     self.markerCount = [[dicPole objectForKey:@"markerNum"] intValue];
                     GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[[dicPole objectForKey:@"poleLat"] doubleValue] longitude:[[dicPole objectForKey:@"poleLong"] doubleValue] zoom:18];
                     self.mapView_.camera = camera;
                     GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:self.path];
                     GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withPadding:100];
                     [self.mapView_ moveCamera:update];
                     self.mapView_.hidden = NO;
                     self.activityIndicator.hidden = YES;
                 }
                 //No Light Poles Exist
                 else
                 {
                     [self startLocationManager];
                 }
                 
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
}

//Mapview Delegate Methods ************************************************************
-(void)mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)marker
{
    for(int i = 0; i < self.arrayMarkers.count; i++)
    {
        GMSMarker *tmpMarker = [self.arrayMarkers objectAtIndex:i];
        if([tmpMarker isEqual:marker])
        {
            [self.arrayMarkers replaceObjectAtIndex:i withObject:marker];
            
            NSDictionary *dicMarker = marker.userData;
            
            NSString *myRequestString = [NSString stringWithFormat:@"poleID=%@&poleLat=%f&poleLong=%f&userID=%@", dicMarker[@"poleID"], marker.position.latitude, marker.position.longitude, [UserInfoGlobal userID]];
            
            // Create Data from request
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
            
            break;
        }
    }
}

/*
-(void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"Long Press");
} */

-(void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"Tap Map");
    
    if(self.markerWindowIsOpen)
        self.markerWindowIsOpen = NO;
    else //Create a new marker
    {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
        marker.draggable = YES;
        marker.map = self.mapView_;
        
        self.markerGlobalVar = marker;
        ++self.markerCount;
        
        //Wait one second before loading Marker Info View
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(loadMarkerInfoView:) userInfo:nil repeats:NO];
    }
}

-(void)loadMarkerInfoView:(SEL)loadMarkerInfoView
{
    [self performSegueWithIdentifier:@"MapToMarkerInfo" sender:self];
}

-(UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker
{
    NSLog(@"Marker Window");
    
    self.markerWindowIsOpen = YES;
    
    return nil;
}


-(BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    NSLog(@"Tapped Marker");
    
    if(self.markerWindowIsOpen)
        self.markerWindowIsOpen = NO;
    
    return false;
}

-(void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    self.markerGlobalVar = marker;
    self.mapView_.selectedMarker = nil;
    self.markerWindowIsOpen = NO;
    [self performSegueWithIdentifier:@"MapToMarkerInfo" sender:self];
}

- (IBAction)cancelBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}


-(void)doneMarkerInfo:(GMSMarker *)marker isNewMarker:(BOOL)isNewMarker
{
    [self.navigationController popViewControllerAnimated:YES];
    
    if(isNewMarker)
    {
        if(marker.userData == NULL)
        {
            //Delete Marker
            marker.map = nil;
            --self.markerCount;
            return;
        }
        
        NSMutableDictionary *dicMarker = marker.userData;
        
        //Insert new row in database
        NSString *myRequestString = [NSString stringWithFormat:@"projectID=%@&markerNum=%@&poleLat=%f&poleLong=%f&poleExist=%@&numHeads=%@&bulbID=%@&assemblyTypeID=%@&legacyWattage=%@&hasPicture=%@&oneToOneReplace=%@&numHeadsProposed=%@&poleHeight=%@&ledFixtureID=%@&bracket=%@&userID=%@", self.strProjectID, dicMarker[@"markerNum"], marker.position.latitude, marker.position.longitude, dicMarker[@"poleExist"], dicMarker[@"numOfHeads"], dicMarker[@"bulbTypeID"], dicMarker[@"assemblyTypeID"], dicMarker[@"wattage"], dicMarker[@"hasPicture"], dicMarker[@"oneToOneReplace"], dicMarker[@"numOfHeadsProposed"], dicMarker[@"height"], dicMarker[@"LEDFixtureID"], dicMarker[@"bracket"], [UserInfoGlobal userID]];

        NSData *myRequestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
        NSString *URL = [NSString stringWithFormat:@"%@/iOS/LightPoles/newPole.php", [UserInfoGlobal serverURL]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];
        [request setHTTPMethod: @"POST"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [request setHTTPBody: myRequestData];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData * data,NSError * error)
         {
             if(!error)
             {
                 NSDictionary *dicServerMessage = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                 
                 //Insert Success
                 if([[dicServerMessage objectForKey:@"success"] isEqualToNumber:@1])
                 {
                     //Add Pole/Marker ID to marker
                     dicMarker[@"poleID"] = [dicServerMessage objectForKey:@"message"];
                     marker.userData = dicMarker;
                     
                     //Add Picture URL
                     if([dicMarker[@"hasPicture"] isEqualToString:@"1"])
                     {
                         [self uploadImage:dicMarker[@"pictureData"] filename:dicMarker[@"poleID"]];
                         [dicMarker removeObjectForKey:@"pictureData"];
                     }
                     //Add to Array
                     [self.arrayMarkers addObject:marker];
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
        
        //Update City and State for first Light Pole
        if(self.markerCount == 1)
        {
            CLLocation *location = [[CLLocation alloc] initWithLatitude:marker.position.latitude longitude:marker.position.longitude];
            CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
            [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
            {
                for(CLPlacemark * placemark in placemarks)
                {
                    NSString *city = [placemark locality];
                    NSString *state = [placemark administrativeArea];

                    NSString *myRequestString = [NSString stringWithFormat:@"userID=%@&city=%@&state=%@&projectID=%@&projectLat=%f&projectLong=%f", [UserInfoGlobal userID], city, state, self.strProjectID, marker.position.latitude, marker.position.longitude];
                    
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
            }];
        }
    }
    else
    {
        if(marker.userData == NULL)
        {
            //Remove marker from array
            for(int i = 0; i < self.arrayMarkers.count; i++)
            {
                GMSMarker *tmpMarker = self.arrayMarkers[i];
                if([tmpMarker isEqual:marker])
                {
                    [self.arrayMarkers removeObjectAtIndex:i];
                    break;
                }
            }
            
            //Delete Marker
            marker.map = nil;
            return;
        }
    }
}

- (void)doneMapDetails:(NSMutableDictionary *)dicProjectDetails andStatus:(BOOL)isNewProject
{
    [self.navigationController popViewControllerAnimated:YES];
    
    self.navigationItem.title = dicProjectDetails[@"projectName"];
    self.strCostPerKWH = dicProjectDetails[@"cost"];
    self.strDateOfService = dicProjectDetails[@"dateOfService"];
    self.strNameOfRep = dicProjectDetails[@"contactName"];
    self.strPhone = dicProjectDetails[@"contactPhone"];
    self.strEmail = dicProjectDetails[@"contactEmail"];
    self.strComments = dicProjectDetails[@"comments"];
    self.strDailyUsageHours = dicProjectDetails[@"dailyUsageHours"];
    
    if(isNewProject)
    {
        //Insert new row in database
        NSString *myRequestString = [NSString stringWithFormat:@"projectName=%@&userID=%@&powerCost=%@&dateOfService=%@&contactName=%@&contactPhone=%@&contactEmail=%@&comments=%@&dailyUsageHours=%@", self.navigationItem.title, [UserInfoGlobal userID], self.strCostPerKWH, self.strDateOfService, self.strNameOfRep, self.strPhone, self.strEmail, self.strComments, self.strDailyUsageHours];

        NSData *myRequestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
        NSString *URL = [NSString stringWithFormat:@"%@/iOS/Projects/newProject.php", [UserInfoGlobal serverURL]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];
        [request setHTTPMethod: @"POST"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [request setHTTPBody: myRequestData];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData * data,NSError * error)
         {
             if(!error)
             {
                 NSDictionary *dicServerMessage = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                 
                 //Insert Success
                 if([[dicServerMessage objectForKey:@"success"] isEqualToNumber:@1])
                     self.strProjectID = [dicServerMessage objectForKey:@"message"];
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
    else
    {
        //Update database
        NSString *myRequestString = [NSString stringWithFormat:@"projectName=%@&userID=%@&powerCost=%@&dateOfService=%@&contactName=%@&contactPhone=%@&contactEmail=%@&comments=%@&dailyUsageHours=%@&projectID=%@", self.navigationItem.title, [UserInfoGlobal userID], self.strCostPerKWH, self.strDateOfService, self.strNameOfRep, self.strPhone, self.strEmail, self.strComments, self.strDailyUsageHours, self.strProjectID];

        NSData *myRequestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
        NSString *URL = [NSString stringWithFormat:@"%@/iOS/Projects/updateProject.php", [UserInfoGlobal serverURL]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];
        [request setHTTPMethod: @"POST"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [request setHTTPBody: myRequestData];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData * data,NSError * error)
         {
             if (!error)
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
    
    self.isNewProject = NO;
    
}
//Mapview Delegate Methods DONE ***********************************************************

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"MapToMarkerInfo"])
    {
        MarkerInfoDelegate *vc = segue.destinationViewController;
        vc.delegate = self;
        vc.marker = self.markerGlobalVar;
        vc.markerCount = @(self.markerCount);
        if(self.arrayMarkers.count > 0)
        {
            GMSMarker *mostRecentMarker = [self.arrayMarkers objectAtIndex:(self.arrayMarkers.count - 1)];
            vc.markerPrevious = mostRecentMarker;
        }
    }
    else if([segue.identifier isEqualToString:@"MapToCalculateArea"])
    {
        CalculateArea *vc = segue.destinationViewController;
        vc.latitudeCurrentLocation = self.latitudeCurrentLocation;
        vc.longitudeCurrentLocation = self.longitudeCurrentLocation;
        vc.arrayLightPoles = self.arrayMarkers;
        vc.strProjectID = self.strProjectID;
    }
    else if([segue.identifier isEqualToString:@"MapToMapDetails"])
    {
        MapDetailsDelegate *vc = segue.destinationViewController;
        vc.delegate = self;
        vc.isNewProject = self.isNewProject;
        vc.strProjectName = self.navigationItem.title;
        vc.strCost = self.strCostPerKWH;
        vc.strDateOfService = self.strDateOfService;
        vc.strNameOfRep = self.strNameOfRep;
        vc.strPhone = self.strPhone;
        vc.strEmail = self.strEmail;
        vc.strComments = self.strComments;
        vc.strDailyUsageHours = self.strDailyUsageHours;
    }
}

@end
