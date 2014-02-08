//
//  ViewController.m
//  Stone
//
//  Created by Kenneth Siu on 2/7/14.
//  Copyright (c) 2014 Kenneth Siu. All rights reserved.
//

#import "ViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "APIKey.h"
#import "Marker.h"
#import "MBProgressHUD.h"

@interface ViewController ()

@end

@implementation ViewController {
    GMSMapView *mapView_;
    BOOL initial_;
    CLLocation *newLocation_;
    GMSMarker *tempMark;
}

@synthesize locationManager, insertMsg, removeMark, rateMark, addMark, profileName, profileNameChange, url;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //location manager to ask for location every so often
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    locationManager.delegate = self;
    
    //dummy camera set up initially
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:0
                                                            longitude:0
                                                                 zoom:15];
    mapView_ = [GMSMapView mapWithFrame:[[UIScreen mainScreen] bounds] camera:camera];
    
    //set map view delegate to self
    mapView_.delegate = self;
    
    //show blue button and enable location for user
    mapView_.settings.myLocationButton = YES;
    mapView_.myLocationEnabled = YES;
    
    //used for initial camera setup
    initial_ = YES;
    
    //start updating locations
    [locationManager startUpdatingLocation];
    
    //set view
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //set up button
    insertMsg = [UIButton buttonWithType:UIButtonTypeCustom];
    [insertMsg addTarget:self action:@selector(insertMessage:) forControlEvents:UIControlEventTouchDown];
    [insertMsg setTitle:@"Insert Msg" forState:UIControlStateNormal];
    [insertMsg.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [insertMsg.layer setBackgroundColor:[[UIColor grayColor] CGColor]];
    [insertMsg setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [insertMsg.layer setBorderWidth:2.0f];
    insertMsg.layer.cornerRadius = 10;
    insertMsg.clipsToBounds = YES;
    insertMsg.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    insertMsg.frame = CGRectMake(95.0, self.view.bounds.size.height - insertMsg.bounds.size.height - 50, 130.0, 40.0);
    
    //set profile to default user
    profileName = @"Jon";
    
    //set up url
    APIKey *key = [[APIKey alloc] init];
    url = key.apiURL;
    
    //add map to view
    [self.view addSubview:mapView_];
    [self.view addSubview:insertMsg];
    
    //timer
    NSTimer *time = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                     target:self
                                                   selector:@selector(refreshMarkers:)
                                                   userInfo:nil
                                                    repeats:YES];
    [time fire];
    
    //set edit profile name
    UIBarButtonItem *anchorLeftButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit Profile" style:UIBarButtonItemStylePlain target:self action:@selector(changeToSettings)];
    
    self.navigationItem.leftBarButtonItem = anchorLeftButton;
    
}

- (void) refreshMarkers:(NSTimer*) timer {
    
    //get markers within 500 foot radius
    NSData* data = [API getMarkers:url location:newLocation_ radiusInFeet:5280];
    
    if(data != nil) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:data
                              options:kNilOptions
                              error:&error];

        
        for(NSDictionary *dict in json) {
            Marker *mark = [[Marker alloc] initWithID:[dict objectForKey:@"_id"] rating:[(NSString*)[dict objectForKey:@"rating"] intValue]];
            CLLocationCoordinate2D position = CLLocationCoordinate2DMake([(NSString*)[dict objectForKey:@"lat"] floatValue], [(NSString*)[dict objectForKey:@"lon"] floatValue]);
            GMSMarker *marker = [GMSMarker markerWithPosition:position];
            marker.title = [dict objectForKey:@"username"];
            marker.snippet = [dict objectForKey:@"message"];
            marker.map = mapView_;
            marker.userData = mark;
        }
    }
    
}

- (void) insertMessage:(UIButton*) button {
    button.selected = YES;
    //change color on background
    [button setBackgroundColor:[UIColor lightGrayColor]];
    
    //time to pop up new view controller
    addMark = [[UIAlertView alloc] initWithTitle:@"Message" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    addMark.alertViewStyle = UIAlertViewStylePlainTextInput;
    [addMark show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    //set location to new location
    newLocation_ = newLocation;
    
    if(initial_) {
        //set camera to current location if initial set up
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:newLocation.coordinate.latitude
                                                                longitude:newLocation.coordinate.longitude
                                                                     zoom:17];
        [mapView_ animateToCameraPosition:camera];
        initial_ = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (BOOL) didTapMyLocationButtonForMapView: (GMSMapView *) mapView	{
    
    //if my location button clicked, go back to current location
    CLLocation *loc = mapView.myLocation;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:loc.coordinate.latitude
                                                            longitude:loc.coordinate.longitude
                                                                 zoom:17];
    
    [mapView animateToCameraPosition:camera];
    
    return YES;
}

- (BOOL) mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    // if marker is hit
    tempMark = marker;
    if(marker.title == profileName) {
        removeMark = [[UIAlertView alloc] initWithTitle:marker.title message:marker.snippet delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [removeMark show];
    } else {
        rateMark = [[UIAlertView alloc] initWithTitle:marker.title message:marker.snippet delegate:self cancelButtonTitle:@"Rate Down" otherButtonTitles:@"Hide", @"Rate Up", nil];
        [rateMark show];
    }
    
    
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) changeToSettings {
    //change to settings view
    //[mapView_ removeFromSuperview];
    //[insertMsg removeFromSuperview];
    //UINavigationController *nav = (UINavigationController*)self.slidingViewController.topViewController;
    //nav.navigationBar.topItem.title = @"Settings";
    
    profileNameChange = [[UIAlertView alloc] initWithTitle:@"Insert Profile Name" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    profileNameChange.alertViewStyle = UIAlertViewStylePlainTextInput;
    [profileNameChange show];
}

- (void) changeToMap {
    //readd map view
    [self.view addSubview:mapView_];
    [self.view addSubview:insertMsg];
    UINavigationController *nav = (UINavigationController*)self.slidingViewController.topViewController;
    nav.navigationBar.topItem.title = @"Stone";
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if([alertView isEqual:addMark]) {
        //if user presses cancel
        if(buttonIndex == 0) {
            [insertMsg setBackgroundColor:[UIColor whiteColor]];
            return;
        }
        
        UITextField *textBox = [alertView textFieldAtIndex:0];
        
        textBox = [alertView textFieldAtIndex:0];
        [insertMsg setBackgroundColor:[UIColor whiteColor]];
        
        //insert marker (only if text is not 0)
        if([textBox.text length] != 0) {
            CLLocationCoordinate2D position = CLLocationCoordinate2DMake(newLocation_.coordinate.latitude, newLocation_.coordinate.longitude);
            GMSMarker *marker = [GMSMarker markerWithPosition:position];
            marker.title = profileName;
            marker.snippet = textBox.text;
            marker.map = mapView_;
            
            //connect with api
            NSData *data;
            data = [API postMarker:url message:marker.snippet location:newLocation_ username:profileName];
            
            if(data != nil) {
                NSError* error;
                NSDictionary* json = [NSJSONSerialization
                                      JSONObjectWithData:data
                                      options:kNilOptions
                                      error:&error];
                
                if([(NSNumber*)[json objectForKey:@"success"] isEqualToNumber:[NSNumber numberWithInt:1]]) {
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                    
                    // Configure for text only and offset down
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = @"Successfully added!!";
                    hud.margin = 10.f;
                    hud.yOffset = 150.f;
                    hud.removeFromSuperViewOnHide = YES;
                    
                    [hud hide:YES afterDelay:2];
                }
            } else {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                
                // Configure for text only and offset down
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"Could not add marker to server...";
                hud.margin = 10.f;
                hud.yOffset = 150.f;
                hud.removeFromSuperViewOnHide = YES;
                
                [hud hide:YES afterDelay:2];
                marker.map = nil;
            }
            
        }
    } else if([alertView isEqual:rateMark]) {
        NSData *data;
        
        //if hide, just return
        if(buttonIndex == 1) {
            tempMark = nil;
            return;
        }
        
        //down vote
        if(buttonIndex == 0) {
            data = [API vote:url id:((Marker*)tempMark.userData).ID amount:1 dir:-1];
            tempMark = nil;
        }
        
        //up vote
        if(buttonIndex == 2) {
            data = [API vote:url id:((Marker*)tempMark.userData).ID amount:1 dir:1];
            tempMark = nil;
        }
        
        if(data != nil) {
            NSError* error;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:kNilOptions
                                  error:&error];
            
            if([(NSNumber*)[json objectForKey:@"success"] isEqualToNumber:[NSNumber numberWithInt:1]]) {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                
                // Configure for text only and offset down
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"Successfully voted!";
                hud.margin = 10.f;
                hud.yOffset = 150.f;
                hud.removeFromSuperViewOnHide = YES;
                
                [hud hide:YES afterDelay:2];
            }
        } else {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            
            // Configure for text only and offset down
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"Could not connect to server.";
            hud.margin = 10.f;
            hud.yOffset = 150.f;
            hud.removeFromSuperViewOnHide = YES;
            
            [hud hide:YES afterDelay:2];
        }

        return;
        
    } else if([alertView isEqual:removeMark]) {
        tempMark = nil;
        return;
    } else if([alertView isEqual:profileNameChange]) {
        
        //if user presses cancel
        if(buttonIndex == 0) {
            return;
        }
        
        //however, if not empty, set profile name to this
        if([[alertView textFieldAtIndex:0].text length] != 0) {
            profileName = [[alertView textFieldAtIndex:0] text];
        }
        
        return;
        
    }
    
    
}

@end
