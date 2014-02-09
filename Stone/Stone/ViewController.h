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
@property (nonatomic, strong) NSMutableArray *arrMark;
@property (nonatomic, strong) UIAlertView *chooseMark;
@property (nonatomic, strong) NSMutableArray *tempArr;
@property (nonatomic, strong) NSString *uid;

- (void) changeToSettings;
- (void) changeToMap;
- (float) getDistance:(float)loc1Lat loc1Long:(float)loc1Long loc2Lat:(float)loc2Lat  loc2Long:(float)loc2Long;

+ (NSString*) parseSpace:(NSString*)str;

@end
