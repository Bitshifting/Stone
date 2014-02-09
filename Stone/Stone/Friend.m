//
//  Friend.m
//  Stone
//
//  Created by Kenneth Siu on 2/8/14.
//  Copyright (c) 2014 Kenneth Siu. All rights reserved.
//

#import "Friend.h"

@implementation Friend

-(id) initWithID:(NSString *)uid displayName:(NSString*)displayName {
    
    if(self = [super init]) {
        _uid = uid;
        _displayName = displayName;
    }
    
    return self;
}

@end
