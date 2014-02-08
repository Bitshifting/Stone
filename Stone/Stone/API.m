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
    NSURL *urlSend =[NSURL URLWithString:[NSString stringWithFormat:@"%@/stoneapi/get_local_metadata/%f/%f/%f", url, loc.coordinate.latitude, loc.coordinate.longitude, feet]];
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:urlSend] returningResponse:&urlResponse error:&requestError];
    
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    return data;
    
}

+ (NSData*) getMarker:(NSString*)url id:(NSString*)ID {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *urlSend =[NSURL URLWithString:[NSString stringWithFormat:@"%@/stoneapi/get_message_content/%@", url, ID]];
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:urlSend] returningResponse:&urlResponse error:&requestError];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    return data;
}

+ (NSData*) postMarker:(NSString*)url message:(NSString*)msg location:(CLLocation*)loc username:(NSString*)user {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *urlSend =[NSURL URLWithString:[NSString stringWithFormat:@"%@/stoneapi/post_message/%@/%f/%f/%@", url, msg, loc.coordinate.latitude, loc.coordinate.longitude, user]];
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:urlSend] returningResponse:&urlResponse error:&requestError];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    return data;
}

+ (NSData*) vote:(NSString*)url id:(NSString*)ID amount:(NSInteger)amt dir:(NSInteger)dir {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *urlSend =[NSURL URLWithString:[NSString stringWithFormat:@"%@/stoneapi/vote/%@/%d/%d", url, ID, amt, dir]];
    NSError *requestError;
    NSLog(@"%@", [urlSend path]);
    NSURLResponse *urlResponse = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:urlSend] returningResponse:&urlResponse error:&requestError];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    return data;
}

@end
