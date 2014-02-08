//
//  API.h
//  Stone
//
//  Created by Kenneth Siu on 2/8/14.
//  Copyright (c) 2014 Kenneth Siu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>

@interface API : NSObject

+ (NSData*) getMarkers:(NSString*)url location:(CLLocation*)loc radiusInFeet:(float)feet;
+ (NSData*) getMarker:(NSString*)url id:(NSString*)ID;
+ (NSData*) postMarker:(NSString*)url message:(NSString*)msg location:(CLLocation*)loc username:(NSString*)user;
+ (NSData*) vote:(NSString*)url id:(NSString*)ID amount:(NSInteger)amt dir:(NSInteger)dir;

@end
