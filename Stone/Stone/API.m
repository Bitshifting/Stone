//
//  API.m
//  Stone
//
//  Created by Kenneth Siu on 2/8/14.
//  Copyright (c) 2014 Kenneth Siu. All rights reserved.
//

#import "API.h"

@implementation API

+ (NSData*) getMarkers:(NSString*)url location:(CLLocation*)loc radiusInFeet:(float)feet {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *urlSend =[NSURL URLWithString:[NSString stringWithFormat:@"%@/stoneapi/message/get/%f/%f/%f", url, loc.coordinate.latitude, loc.coordinate.longitude, feet]];
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:urlSend] returningResponse:&urlResponse error:&requestError];
    
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    return data;
    
}

+ (NSData*) postMarker:(NSString*)url message:(NSString*)msg location:(CLLocation*)loc username:(NSString*)user recipient:(NSString*)rec {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *urlSend =[NSURL URLWithString:[NSString stringWithFormat:@"%@/stoneapi/message/post/%@/%f/%f/%@/%@", url, msg, loc.coordinate.latitude, loc.coordinate.longitude, user, rec]];
    NSLog(@"URL: %@", [urlSend path]);
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:urlSend] returningResponse:&urlResponse error:&requestError];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    return data;
}

+ (NSData*) vote:(NSString*)url id:(NSString*)ID amount:(NSInteger)amt dir:(NSInteger)dir {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *urlSend =[NSURL URLWithString:[NSString stringWithFormat:@"%@/stoneapi/message/vote/%@/%d/%d", url, ID, amt, dir]];
    NSError *requestError;
    NSLog(@"%@", [urlSend path]);
    NSURLResponse *urlResponse = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:urlSend] returningResponse:&urlResponse error:&requestError];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    return data;
}

//friends api
+ (NSData*) createName:(NSString*)url name:(NSString*)name {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *urlSend =[NSURL URLWithString:[NSString stringWithFormat:@"%@/stoneapi/account/create/%@", url, name]];
    NSError *requestError;
    NSLog(@"%@", [urlSend path]);
    NSURLResponse *urlResponse = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:urlSend] returningResponse:&urlResponse error:&requestError];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    return data;
}

+ (NSData*) updateName:(NSString*)url uid:(NSInteger)uid displayName:(NSString*)displayName {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *urlSend =[NSURL URLWithString:[NSString stringWithFormat:@"%@/stoneapi/account/update/%d/%@", url, uid, displayName]];
    NSError *requestError;
    NSLog(@"%@", [urlSend path]);
    NSURLResponse *urlResponse = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:urlSend] returningResponse:&urlResponse error:&requestError];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    return data;
}

+ (NSData*) lookup:(NSString*)url lookupName:(NSString*)displayName {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *urlSend =[NSURL URLWithString:[NSString stringWithFormat:@"%@/stoneapi/account/lookup/%@", url, displayName]];
    NSError *requestError;
    NSLog(@"%@", [urlSend path]);
    NSURLResponse *urlResponse = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:urlSend] returningResponse:&urlResponse error:&requestError];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    return data;
}

+ (NSData*) addFriend:(NSString*)url uid:(NSInteger)uid displayName:(NSString*)displayName {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *urlSend =[NSURL URLWithString:[NSString stringWithFormat:@"%@/stoneapi/account/addfriend/%d/%@", url, uid, displayName]];
    NSError *requestError;
    NSLog(@"%@", [urlSend path]);
    NSURLResponse *urlResponse = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:urlSend] returningResponse:&urlResponse error:&requestError];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    return data;
}

+ (NSData*) delFriend:(NSString*)url uid:(NSInteger)uid displayName:(NSString*)displayName {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *urlSend =[NSURL URLWithString:[NSString stringWithFormat:@"%@/stoneapi/account/delfriend/%d/%@", url, uid, displayName]];
    NSError *requestError;
    NSLog(@"%@", [urlSend path]);
    NSURLResponse *urlResponse = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:urlSend] returningResponse:&urlResponse error:&requestError];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    return data;
}

+ (NSData*) getFriends:(NSString*)url uid:(NSInteger)uid {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *urlSend =[NSURL URLWithString:[NSString stringWithFormat:@"%@/stoneapi/account/update/%d", url, uid]];
    NSError *requestError;
    NSLog(@"%@", [urlSend path]);
    NSURLResponse *urlResponse = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:urlSend] returningResponse:&urlResponse error:&requestError];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    return data;
}
@end
