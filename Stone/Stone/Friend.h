//
//  Friend.h
//  Stone
//
//  Created by Kenneth Siu on 2/8/14.
//  Copyright (c) 2014 Kenneth Siu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Friend : NSObject

@property NSString *uid;
@property NSString *displayName;

-(id) initWithID:(NSString*)uid displayName:(NSString*)displayName;

@end
