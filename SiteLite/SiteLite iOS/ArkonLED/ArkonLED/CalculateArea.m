//
//  CalculateArea.m
//  ArkonLED
//
//  Created by Michael Nation on 9/13/14.
//  Copyright (c) 2014 ArkonLED. All rights reserved.
//

#import "CalculateArea.h"

@interface CalculateArea ()

@property() BOOL markerWindowIsOpen;
@property() double area;

@end


@implementation CalculateArea

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
    // Do any additional setup after loading the view.
    
    self.navigationController.toolbarHidden = NO;
    
    //self.mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView_ = [[GMSMapView alloc] initWithFrame:self.view.bounds];
    self.mapView_.delegate = self;
    //self.mapView_.camera = camera;
    self.mapView_.myLocationEnabled = YES;
    //self.mapView_.mapType = kGMSTypeSatellite;
    self.mapView_.mapType = kGMSTypeHybrid;
    //self.view = self.mapView_;
    [self.mapView_ setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    self.mapView_.hidden = YES;
    [self.view insertSubview:self.mapView_ atIndex:0];
    
    //Initialize Array
    self.arrayAreaMarkers = [[NSMutableArray alloc] init];
    self.area = 0;
    self.markerWindowIsOpen = NO;
    
    //Get Light Pole Markers
    NSString *URL = [NSString stringWithFormat:@"%@/iOS/CalculateArea/getLotAreaMarkers.php?projectID=%@&userID=%@", [UserInfoGlobal serverURL], self.strProjectID, [UserInfoGlobal userID]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];
    // set Request Type
    [request setHTTPMethod: @"GET"];
    // Set content-type
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    // Now send a request and get Response
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData * data,NSError * error)
     {
         if(!error)
         {
             NSDictionary *dicServerMessage = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
             
             //Successful
             if([[dicServerMessage objectForKey:@"success"] isEqualToNumber:@1])
             {
                 GMSCameraPosition *camera;
                 NSArray *arrayResponse = [dicServerMessage objectForKey:@"message"];
                 
                 if(arrayResponse.count > 0)
                 {
                     self.rect = [GMSMutablePath path];
                     
                     int i;
                     NSDictionary *dicAreaMarker;
                     for(i = 0; i < arrayResponse.count; i++)
                     {
                         dicAreaMarker = [arrayResponse objectAtIndex:i];
                         
                         // Create a marker
                         GMSMarker *marker = [[GMSMarker alloc] init];
                         marker.position = CLLocationCoordinate2DMake([[dicAreaMarker objectForKey:@"latitude"] doubleValue], [[dicAreaMarker objectForKey:@"longitude"] doubleValue]);
                         marker.draggable = YES;
                         marker.title = @"Delete";
                         marker.icon = [GMSMarker markerImageWithColor:[UIColor yellowColor]];
                         marker.map = self.mapView_;
                         
                         [self.rect addCoordinate:marker.position];
                         
                         //Add to Array
                         [self.arrayAreaMarkers addObject:marker];
                     }
                     
                     
                     camera = [GMSCameraPosition cameraWithLatitude:[[dicAreaMarker objectForKey:@"latitude"] doubleValue] longitude:[[dicAreaMarker objectForKey:@"longitude"] doubleValue] zoom:18];
                     
                     [self calculateAreaClicked:self];
                 }
                 //No Area Markers Exist
                 else
                 {
                     //Set to location of last Light Pole
                     if(self.arrayLightPoles.count > 0)
                     {
                         GMSMarker *lastMarker = [self.arrayLightPoles objectAtIndex:self.arrayLightPoles.count - 1];
                         camera = [GMSCameraPosition cameraWithLatitude:lastMarker.position.latitude longitude:lastMarker.position.longitude zoom:18];
                     }
                     //Set to Current Location
                     else
                     {
                         camera = [GMSCameraPosition cameraWithLatitude:self.latitudeCurrentLocation longitude:self.longitudeCurrentLocation zoom:18];
                     }
                 }
                 
                 self.mapView_.camera = camera;
                 GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:self.rect];
                 GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withPadding:100];
                 [self.mapView_ moveCamera:update];
                 self.mapView_.hidden = NO;
                 self.activityIndicator.hidden = YES;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backBtnClicked:(id)sender
{
    //Hide Bottom Toolbar
    self.navigationController.toolbarHidden = YES;
    
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)calculateAreaClicked:(id)sender
{
    self.mapView_.selectedMarker = nil;
    self.markerWindowIsOpen = NO;
    
    if(self.arrayAreaMarkers.count < 3)
    {
        UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"WARNING" message:@"Minimum of 3 light poles required to calculate an area." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [errorView show];
        return;
    }
    
    self.polygon.map = nil;
    self.polygon = nil;
    self.polygon = [GMSPolygon polygonWithPath:self.rect];
    self.polygon.map = self.mapView_;
    
    self.area = GMSGeometryArea(self.rect) * 10.76391111;
    self.lblArea.title = [NSString stringWithFormat:@"%.0f ft\u00B2", self.area];
}

- (IBAction)doneBtnClicked:(id)sender
{
    //Create markers string
    NSMutableString *strMarkerCoordinates = [[NSMutableString alloc] initWithString:@""];
    
    if(self.lblArea.title != nil && ![self.lblArea.title isEqualToString:@""])
    {
        GMSMarker *tmpMarker;
        int i;
        for(i = 0; i < self.arrayAreaMarkers.count - 1; i++)
        {
            tmpMarker = [self.arrayAreaMarkers objectAtIndex:i];
            //strMarkerCoordinates = [NSString stringWithFormat:@"%@%f_%f,", strMarkerCoordinates, tmpMarker.position.latitude, tmpMarker.position.longitude];
            [strMarkerCoordinates appendString:[NSString stringWithFormat:@"%f_%f,", tmpMarker.position.latitude, tmpMarker.position.longitude]];
        }
        tmpMarker = [self.arrayAreaMarkers objectAtIndex:i];
        //strMarkerCoordinates = [NSString stringWithFormat:@"%@%f_%f", strMarkerCoordinates, tmpMarker.position.latitude, tmpMarker.position.longitude];
        [strMarkerCoordinates appendString:[NSString stringWithFormat:@"%f_%f", tmpMarker.position.latitude, tmpMarker.position.longitude]];
    }
    
    //NSString *myRequestString = [NSString stringWithFormat:@"projectID=%@&area=%@&markers=%@&userID=%@", self.strProjectID, self.lblArea.title, strMarkerCoordinates, [UserInfoGlobal userID]];
    NSString *myRequestString = [NSString stringWithFormat:@"projectID=%@&area=%f&markers=%@&userID=%@", self.strProjectID, self.area, strMarkerCoordinates, [UserInfoGlobal userID]];
    
    //NSLog(@"%@", myRequestString); return;
    
    // Create Data from request
    NSData *myRequestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
    NSString *URL = [NSString stringWithFormat:@"%@/iOS/CalculateArea/addLotAreaMarkers.php", [UserInfoGlobal serverURL]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];
    // set Request Type
    [request setHTTPMethod: @"POST"];
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
             
             //DB Success. Pop to Project List
             if([[dicServerMessage objectForKey:@"success"] isEqualToNumber:@1])
             {
                 //Hide Bottom Toolbar
                 self.navigationController.toolbarHidden = YES;
                 
                 [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
             }
             //DB Failed
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


- (IBAction)clearMarkersBtnClicked:(id)sender
{
    [self.mapView_ clear];
    [self.arrayAreaMarkers removeAllObjects];
    self.area = 0;
    self.lblArea.title = @"";
}


//Update Coordinates after Dragging Marker
-(void)mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)marker
{
    for(int i = 0; i < self.arrayAreaMarkers.count; i++)
    {
        GMSMarker *tmpMarker = [self.arrayAreaMarkers objectAtIndex:i];
        if([tmpMarker isEqual:marker])
        {
            marker.position = CLLocationCoordinate2DMake([[NSString stringWithFormat:@"%.6f", marker.position.latitude] doubleValue], [[NSString stringWithFormat:@"%.6f", marker.position.longitude] doubleValue]);
            
            [self.arrayAreaMarkers replaceObjectAtIndex:i withObject:marker];
            break;
        }
    }
    
    self.area = 0;
    
    self.polygon.map = nil;
    self.polygon = nil;
    self.rect = nil;
    self.rect = [GMSMutablePath path];
    for(int i = 0; i < self.arrayAreaMarkers.count; i++)
    {
        GMSMarker *tmpMarker = [self.arrayAreaMarkers objectAtIndex:i];
        [self.rect addCoordinate:tmpMarker.position];
    }
    
    self.polyline.map = nil;
    self.polyline = nil;
    self.polyline = [GMSPolyline polylineWithPath:self.rect];
    self.polyline.map = self.mapView_;
    
    [self calculateAreaWithValidation];
}

-(void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"Tap Map");
    
    if(self.markerWindowIsOpen)
    {
        self.markerWindowIsOpen = NO;
    }
    else
    {
        // Create a marker
        GMSMarker *marker = [[GMSMarker alloc] init];
        
        marker.position = CLLocationCoordinate2DMake([[NSString stringWithFormat:@"%.6f", coordinate.latitude] doubleValue], [[NSString stringWithFormat:@"%.6f", coordinate.longitude] doubleValue]);
        marker.draggable = YES;
        marker.title = @"Delete";
        marker.icon = [GMSMarker markerImageWithColor:[UIColor yellowColor]];
        marker.map = self.mapView_;
        
        [self.arrayAreaMarkers addObject:marker];
        
        self.area = 0;
        
        self.polygon.map = nil;
        self.polygon = nil;
        
        self.rect = nil;
        self.rect = [GMSMutablePath path];
        for(int i = 0; i < self.arrayAreaMarkers.count; i++)
        {
            GMSMarker *tmpMarker = [self.arrayAreaMarkers objectAtIndex:i];
            [self.rect addCoordinate:tmpMarker.position];
        }
        
        self.polyline.map = nil;
        self.polyline = nil;
        self.polyline = [GMSPolyline polylineWithPath:self.rect];
        self.polyline.map = self.mapView_;
        
        [self calculateAreaWithValidation];
    }
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
    {
        self.markerWindowIsOpen = NO;
    }
    
    return false;
}

-(void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    self.markerWindowIsOpen = NO;
    
    for(int i = 0; i < self.arrayAreaMarkers.count; i++)
    {
        GMSMarker *tmpMarker = [self.arrayAreaMarkers objectAtIndex:i];
        if([tmpMarker isEqual:marker])
        {
            [self.arrayAreaMarkers removeObjectAtIndex:i];
            marker.map = nil;
            break;
        }
    }
    
    self.area = 0;
    
    self.polygon.map = nil;
    self.polygon = nil;
    self.rect = nil;
    self.rect = [GMSMutablePath path];
    for(int i = 0; i < self.arrayAreaMarkers.count; i++)
    {
        GMSMarker *tmpMarker = [self.arrayAreaMarkers objectAtIndex:i];
        [self.rect addCoordinate:tmpMarker.position];
    }
    
    self.polyline.map = nil;
    self.polyline = nil;
    self.polyline = [GMSPolyline polylineWithPath:self.rect];
    self.polyline.map = self.mapView_;
    
    [self calculateAreaWithValidation];
}

- (void)calculateAreaWithValidation
{
    if(self.arrayAreaMarkers.count >= 3 && ![self.lblArea.title isEqualToString:@""])
    {
        [self calculateAreaClicked:nil];
    }
    else
        self.lblArea.title = @"";
}
@end
