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
#import "LeftViewController.h"
#import "Friend.h"

@interface ViewController ()

@end

@implementation ViewController {
    GMSMapView *mapView_;
    BOOL initial_;
    GMSMarker *tempMark;
    CLLocation *location;
    NSTimer *time;
    NSTimer *time2;
    LeftViewController *leftVC;
}

@synthesize locationManager, insertMsg, removeMark, rateMark, addMark, profileName, profileNameChange, url, arrMark, chooseMark, tempArr, uid;

#pragma mark INIT

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set up url
    APIKey *key = [[APIKey alloc] init];
    url = key.apiURL;
    
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
    [insertMsg setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [insertMsg.layer setBorderWidth:2.0f];
    insertMsg.layer.cornerRadius = 10;
    insertMsg.clipsToBounds = YES;
    insertMsg.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    insertMsg.frame = CGRectMake(95.0, self.view.bounds.size.height - insertMsg.bounds.size.height - 45, 130.0, 40.0);
    
    //initialize array of markers
    arrMark = [[NSMutableArray alloc] init];
    tempArr = [[NSMutableArray alloc] init];
    
    //add map to view
    [self.view addSubview:mapView_];
    [self.view addSubview:insertMsg];
    
    //timer
    time = [NSTimer scheduledTimerWithTimeInterval:2.0
                                            target:self
                                          selector:@selector(refreshMarkers:)
                                          userInfo:nil
                                           repeats:YES];
    [time fire];
    
    
    //timer to check friendship
    //timer
    time2 = [NSTimer scheduledTimerWithTimeInterval:5.0
                                            target:self
                                          selector:@selector(reloadFriends)
                                          userInfo:nil
                                           repeats:YES];
    [time2 fire];
    
    
    //set edit profile name
    UIBarButtonItem *anchorRightButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit Name" style:UIBarButtonItemStylePlain target:self action:@selector(changeToSettings)];
    
    self.navigationItem.rightBarButtonItem = anchorRightButton;
    
    //set friends list
    UIBarButtonItem *anchorLeftButton = [[UIBarButtonItem alloc] initWithTitle:@"See Friends" style:UIBarButtonItemStylePlain target:self action:
                                         @selector(anchorLeft)];
    
    self.navigationItem.leftBarButtonItem = anchorLeftButton;
    
    //get name
    profileName = [[NSUserDefaults standardUserDefaults] stringForKey:@"user"];
    uid = [[NSUserDefaults standardUserDefaults] stringForKey:@"_id"];
    
    if(([profileName length] == 0) || ([uid length] == 0) ) {
        [self changeToSettings];
    } else {
        NSData *data = [API lookup:[ViewController parseSpace:url] lookupName:[ViewController parseSpace:profileName]];
        if(data != nil) {
            NSError* error;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:kNilOptions
                                  error:&error];
            
            if([json count] == 0) {
                //then recreate account and ask for new name
                profileName = @"";
                uid = @"";
                [self changeToSettings];
            }
        }
        
    }
    
    //reload friends
    leftVC = (LeftViewController*)self.slidingViewController.underLeftViewController;
    [leftVC reloadFriends];
    
    leftVC.url = url;
    leftVC.uid = uid;
    
    //set top to profile name
    ((UINavigationController*)self.slidingViewController.topViewController).navigationBar.topItem.title = profileName;
    
}

-(BOOL)shouldAutorotate
{
    
    return UIInterfaceOrientationMaskPortrait;
    
}

-(NSUInteger)supportedInterfaceOrientations
{
    
    return UIInterfaceOrientationMaskPortrait;
    
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    
    return UIInterfaceOrientationPortrait;
    
}

#pragma mark REFRESH MARKERS

- (void) refreshMarkers:(NSTimer*) timer {
    
    [mapView_ clear];
    
    //get markers within 10 mile radius
    NSData* data = [API getMarkers:[ViewController parseSpace:url] location:location radiusInFeet:(5280 * 10)];
    if(data != nil) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:data
                              options:kNilOptions
                              error:&error];
        
        //remove all objects before adding new ones
        [arrMark removeAllObjects];
        
        
        for(NSDictionary *dict in json) {
            Marker *mark = [[Marker alloc] initWithID:[dict objectForKey:@"_id"] rating:[(NSString*)[dict objectForKey:@"rating"] intValue]];
            CLLocationCoordinate2D position = CLLocationCoordinate2DMake([(NSString*)[dict objectForKey:@"lat"] floatValue], [(NSString*)[dict objectForKey:@"lon"] floatValue]);
            GMSMarker *marker = [GMSMarker markerWithPosition:position];
            float distance = [self getDistance:location.coordinate.latitude loc1Long:location.coordinate.longitude loc2Lat:marker.position.latitude loc2Long:marker.position.longitude];
            
            if (distance < 0.1) {
                marker.icon =  [GMSMarker markerImageWithColor:[UIColor greenColor]];
            } else if (distance < 0.5) {
                marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
            } else {
                marker.icon = [GMSMarker markerImageWithColor:[UIColor redColor]];
            }
            
            LeftViewController *left   = (LeftViewController*)self.slidingViewController.underLeftViewController;
            
            NSString *title = [dict objectForKey:@"username"];
            
            for(Friend *fr in left.arrOfFriends) {
                if([title isEqualToString:fr.displayName]) {
                    marker.icon = [GMSMarker markerImageWithColor:[UIColor yellowColor]];
                }
            }
            
            
            marker.title = title;
            marker.snippet = [NSString stringWithFormat:@"[%d] %@",  mark.rating, [dict objectForKey:@"message"]];
            marker.map = mapView_;
            marker.userData = mark;
            [arrMark addObject:marker];
        }
    }
    
}

#pragma mark INIT MESSAGE

- (void) insertMessage:(UIButton*) button {
    button.selected = YES;
    
    //time to pop up new view controller
    addMark = [[UIAlertView alloc] initWithTitle:@"Message" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    addMark.alertViewStyle = UIAlertViewStylePlainTextInput;
    [addMark show];
}

#pragma mark REFRESH LOCATION

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    location = newLocation;
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

#pragma mark TAPPED LOCATION BUTTON

- (BOOL) didTapMyLocationButtonForMapView: (GMSMapView *) mapView	{
    
    //if my location button clicked, go back to current location
    CLLocation *loc = mapView.myLocation;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:loc.coordinate.latitude
                                                            longitude:loc.coordinate.longitude
                                                                 zoom:17];
    
    [mapView animateToCameraPosition:camera];
    
    return YES;
}

#pragma mark TAPPED MARKER

- (BOOL) mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    
    [tempArr removeAllObjects];
    
    float distance = [self getDistance:location.coordinate.latitude loc1Long:location.coordinate.longitude loc2Lat:marker.position.latitude loc2Long:marker.position.longitude];
    
    NSLog(@"%f", distance);
    
    if(distance < .1) {
        //used to determine if need to show more than 1 item
        [tempArr addObject:marker];
        for(GMSMarker *mark in arrMark) {
            if((fabsf(mark.position.latitude - marker.position.latitude) < 0.0000001) && (fabsf(mark.position.longitude - marker.position.longitude) < 0.0000001) && ![marker isEqual:mark]) {
                
                [tempArr addObject:mark];
            }
        }
        
        if([tempArr count] != 1) {
            chooseMark = nil;
            chooseMark = [[UIAlertView alloc] initWithTitle:@"Choose Message (Multiple)" message:nil delegate:self cancelButtonTitle:@"Hide" otherButtonTitles:nil];
            
            for(GMSMarker *mark in tempArr) {
                [chooseMark addButtonWithTitle:[NSString stringWithFormat:@"[%d] %@", ((Marker*)mark.userData).rating, mark.title]];
            }
            
            [chooseMark show];
        } else {
            // if marker is hit
            tempMark = marker;
            
            if([marker.title isEqualToString:profileName]) {
                removeMark = [[UIAlertView alloc] initWithTitle:marker.title message:marker.snippet delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [removeMark show];
            } else {
                rateMark = [[UIAlertView alloc] initWithTitle:marker.title message:marker.snippet delegate:self cancelButtonTitle:@"Hide" otherButtonTitles: @"Upvote", @"Downvote", nil];
                
                [rateMark show];
            }
        }
        
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark SETTINGS PROFILE NAME

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

#pragma mark GO TO MAP

- (void) changeToMap {
    //readd map view
    [self.view addSubview:mapView_];
    [self.view addSubview:insertMsg];
    UINavigationController *nav = (UINavigationController*)self.slidingViewController.topViewController;
    nav.navigationBar.topItem.title = profileName;
}

#pragma mark ALERT VIEW DELEGATE

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
            
            //connect with api
            NSData *data;
            data = [API postMarker:[ViewController parseSpace:url] message:[ViewController parseSpace:textBox.text] location:location username:[ViewController parseSpace:profileName] recipient:@"public"];
            
            if(data != nil) {
                
                CLLocationCoordinate2D position = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
                GMSMarker *marker = [GMSMarker markerWithPosition:position];
                marker.title = profileName;
                marker.snippet = [NSString stringWithFormat:@"[%d] %@", 0, textBox.text];
                marker.map = mapView_;
                
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
            }
            
        }
    } else if([alertView isEqual:chooseMark]) {
        //hide events
        if(buttonIndex == 0) {
            tempMark = nil;
            [tempArr removeAllObjects];
            return;
        }
        
        //specific event
        GMSMarker *marker = [tempArr objectAtIndex:buttonIndex-1];
        tempMark = marker;
        
        //dismiss chosen mark
        [chooseMark dismissWithClickedButtonIndex:0 animated:YES];
        
        if([profileName isEqualToString:marker.title]) {
            removeMark = [[UIAlertView alloc] initWithTitle:marker.title message:marker.snippet delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [removeMark show];
        } else {
            rateMark = [[UIAlertView alloc] initWithTitle:marker.title message:marker.snippet delegate:self cancelButtonTitle:@"Hide" otherButtonTitles: @"Upvote", @"Downvote", nil];
            
            [rateMark show];
        }
        
        
    } else if([alertView isEqual:rateMark]) {
        NSData *data;
        
        
        //if hide, just return
        if(buttonIndex == 0) {
            tempMark = nil;
            return;
        }
        
        //down vote
        if(buttonIndex == 2) {
            data = [API vote:[ViewController parseSpace:url] id:((Marker*)tempMark.userData).ID amount:1 dir:-1];
            tempMark = nil;
        }
        
        //up vote
        if(buttonIndex == 1) {
            data = [API vote:[ViewController parseSpace:url] id:((Marker*)tempMark.userData).ID amount:1 dir:1];
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
            if([profileName length] == 0) {
                [self changeToSettings];
            } else {
                return;
            }
        }
        
        if(buttonIndex == 1) {
            //however, if not empty, set profile name to this
            if([[alertView textFieldAtIndex:0].text length] != 0) {
                profileName = [[alertView textFieldAtIndex:0] text];
            } else if([profileName length] == 0) {
                [self changeToSettings];
            } else {
                return;
            }
        }
        
        //time to create user if uid is nil
        if([uid length] ==  0) {
            NSData *data = [API createName:[ViewController parseSpace:url] name:[ViewController parseSpace:profileName]];
            
            if(data != nil) {
                NSError* error;
                NSDictionary* json = [NSJSONSerialization
                                      JSONObjectWithData:data
                                      options:kNilOptions
                                      error:&error];
                
                if([(NSNumber*)[json objectForKey:@"success"] isEqualToNumber:[NSNumber numberWithInt:1]]) {
                    //if successful, get uid
                    data = [API lookup:[ViewController parseSpace:url] lookupName:[ViewController parseSpace:profileName]];
                    
                    if(data != nil) {
                        NSError* error;
                        NSDictionary* json = [NSJSONSerialization
                                              JSONObjectWithData:data
                                              options:kNilOptions
                                              error:&error];
                        
                        for(NSDictionary *dict in json) {
                            uid = (NSString*)[dict objectForKey:@"_id"];
                            NSLog(@"UID: %@", uid);
                        }
                    } else {
                        //if somehow data is still nil, try again
                        //need to redo if username already taken
                        NSLog(@"Redo username?");
                        [self changeToSettings];
                    }
                    
                } else {
                    [self changeToSettings];
                }
            }
        } else {
            //if uid is not 0, then we can update instead of create
            NSData *data = [API updateName:[ViewController parseSpace:url] uid:uid displayName:[ViewController parseSpace:profileName]];
            
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
                    hud.labelText = @"Name Changed!";
                    hud.margin = 10.f;
                    hud.yOffset = 150.f;
                    hud.removeFromSuperViewOnHide = YES;
                    
                    [hud hide:YES afterDelay:2];
                    [leftVC reloadFriends];
                } else {
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                    
                    // Configure for text only and offset down
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = @"Taken Username";
                    hud.margin = 10.f;
                    hud.yOffset = 150.f;
                    hud.removeFromSuperViewOnHide = YES;
                    
                    [hud hide:YES afterDelay:2];
                    return;
                }
            }
            
        }
        
        //set to user and save
        [[NSUserDefaults standardUserDefaults] setValue:profileName forKey:@"user"];
        [[NSUserDefaults standardUserDefaults] setValue:uid forKey:@"_id"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        ((UINavigationController*)self.slidingViewController.topViewController).navigationBar.topItem.title = profileName;
        
        return;
        
    }
    
    
}

#pragma mark DISTANCE EQUATION

- (float) getDistance:(float)loc1Lat loc1Long:(float)loc1Long loc2Lat:(float)loc2Lat  loc2Long:(float)loc2Long {
    
    //get difference of latitude and longitude in radians
    float dLat = (loc1Lat - loc2Lat) * M_PI / 180;
    float dLon = (loc1Long - loc2Long) * M_PI / 180;
    float lat1 = loc1Lat * M_PI / 180;
    float lat2 = loc2Long * M_PI / 180;
    
    float a = sinf(dLat/2) * sinf(dLat/2) + sinf(dLon/2) * sinf(dLon/2) * cosf(lat1) * cosf(lat2);
    float c = 2 * atan2f(sqrtf(a), sqrtf(1-a));
    return 6371 * c;
}

- (void) anchorLeft {
    
    ECSlidingViewControllerTopViewPosition pos = self.slidingViewController.currentTopViewPosition;
    
    if(pos == 2) {
        [self.slidingViewController anchorTopViewToRightAnimated:YES];
    } else {
        [self.slidingViewController resetTopViewAnimated:YES];
    }
}

- (void) reloadFriends {
    [leftVC reloadFriends];
}

+ (NSString*) parseSpace:(NSString*)str {
    return [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end
