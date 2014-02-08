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
+ (NSData*) postMarker:(NSString*)url message:(NSString*)msg location:(CLLocation*)loc username:(NSString*)user recipient:(NSString*)rec;
+ (NSData*) vote:(NSString*)url id:(NSString*)ID amount:(NSInteger)amt dir:(NSInteger)dir;

//friends
+ (NSData*) createName:(NSString*)url name:(NSString*)name;
+ (NSData*) updateName:(NSString*)url uid:(NSString*)uid displayName:(NSString*)displayName;
+ (NSData*) lookup:(NSString*)url lookupName:(NSString*)displayName;
+ (NSData*) addFriend:(NSString*)url uid:(NSString*)uid displayName:(NSString*)displayName;
+ (NSData*) delFriend:(NSString*)url uid:(NSString*)uid displayName:(NSString*)displayName;
+ (NSData*) getFriends:(NSString*)url uid:(NSString*)uid;

@end
