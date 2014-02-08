//
//  ViewController.m
//  Stone
//
//  Created by Kenneth Siu on 2/7/14.
//  Copyright (c) 2014 Kenneth Siu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController {
    GMSMapView *mapView_;
    BOOL initial_;
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
    [self.view addSubview:mapView_];
    
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

@end
