
//
//  Marker.m
//  Stone
//
//  Created by Kenneth Siu on 2/8/14.
//  Copyright (c) 2014 Kenneth Siu. All rights reserved.
//

#import "Marker.h"

@implementation Marker

@synthesize ID, rating;

-(id) initWithID:(NSString*)tID rating:(NSInteger)rate {
    
    if(self = [super init]) {
        ID = tID;
        rating = rate;
    }
    
    return self;
}

@end
