//
//  Marker.h
//  Stone
//
//  Created by Kenneth Siu on 2/8/14.
//  Copyright (c) 2014 Kenneth Siu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>

@interface Marker : NSObject

@property NSString *ID;
@property NSInteger rating;

-(id) initWithID:(NSString*)tID rating:(NSInteger)rate;

@end
