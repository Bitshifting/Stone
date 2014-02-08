//
//  ViewController.h
//  Stone
//
//  Created by Kenneth Siu on 2/7/14.
//  Copyright (c) 2014 Kenneth Siu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import "API.h"

@interface ViewController : UIViewController <CLLocationManagerDelegate, GMSMapViewDelegate, UIAlertViewDelegate, NSURLConnectionDelegate>

@property (nonatomic,retain) CLLocationManager *locationManager;
@property (nonatomic, strong) UIButton *insertMsg;
@property (nonatomic, strong) UIAlertView *addMark;
@property (nonatomic, strong) UIAlertView *removeMark;
@property (nonatomic, strong) UIAlertView *rateMark;
@property (nonatomic, strong) NSString *profileName;
@property (nonatomic, strong) UIAlertView *profileNameChange;
@property (nonatomic, strong) NSString *url;

- (void) changeToSettings;
- (void) changeToMap;

@end
