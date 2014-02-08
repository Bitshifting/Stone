//
//  ViewController.m
//  Stone
//
//  Created by Kenneth Siu on 2/7/14.
//  Copyright (c) 2014 Kenneth Siu. All rights reserved.
//

#import "ViewController.h"
#import "UIViewController+ECSlidingViewController.h"

@interface ViewController ()

@end

@implementation ViewController {
    GMSMapView *mapView_;
    BOOL initial_;
    BOOL isMap;
}

@synthesize locationManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    locationManager.delegate = self;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:0
                                                            longitude:0
                                                                 zoom:15];
    mapView_ = [GMSMapView mapWithFrame:[[UIScreen mainScreen] bounds] camera:camera];
    
    //set map view delegate to self
    mapView_.delegate = self;
    mapView_.settings.myLocationButton = YES;
    mapView_.myLocationEnabled = YES;
    initial_ = YES;
    
    [locationManager startUpdatingLocation];
    
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:mapView_];
    isMap = YES;
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    if(initial_) {
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
    
    CLLocation *loc = mapView.myLocation;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:loc.coordinate.latitude
                                                            longitude:loc.coordinate.longitude
                                                                 zoom:17];
    
    [mapView animateToCameraPosition:camera];
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) changeToSettings {
    mapView_.hidden = YES;
    UINavigationController *nav = (UINavigationController*)self.slidingViewController.topViewController;
    nav.navigationBar.topItem.title = @"Settings";
}

- (void) changeToMap {
    mapView_.hidden = NO;
    UINavigationController *nav = (UINavigationController*)self.slidingViewController.topViewController;
    nav.navigationBar.topItem.title = @"Stone";
}

@end
