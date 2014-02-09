//
//  AppDelegate.m
//  Stone
//
//  Created by Kenneth Siu on 2/7/14.
//  Copyright (c) 2014 Kenneth Siu. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate ()
@property (nonatomic, strong) ECSlidingViewController *slidingVC;
@property (nonatomic, strong) UINavigationController *navCont;
@end

@implementation AppDelegate

@synthesize topView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    //add google maps api
    APIKey *key = [[APIKey alloc] init];
    [GMSServices provideAPIKey:key.key];
    
    //set up top and left view
    topView = [[ViewController alloc] init];
    
    topView.navigationItem.title = @"";
    
    //navigation controller
    _navCont = [[UINavigationController alloc] initWithRootViewController:topView];
    
    LeftViewController *leftView = [[LeftViewController alloc] init];

    //create left view
    leftView.view.layer.backgroundColor = [UIColor whiteColor].CGColor;
    leftView.edgesForExtendedLayout = UIRectEdgeTop | UIRectEdgeBottom | UIRectEdgeLeft;
    leftView.viewCont = topView;
    
    //set sliding view controller
    self.slidingVC = [ECSlidingViewController slidingWithTopViewController:_navCont];
    self.slidingVC.underLeftViewController = leftView;
    self.slidingVC.underRightViewController = nil;
    self.slidingVC.view.backgroundColor = [UIColor whiteColor];
    
    //enable pan gestures
    [_navCont.view addGestureRecognizer:self.slidingVC.panGesture];
    
    //set how far left view goes
    self.slidingVC.anchorRightPeekAmount = 100.0;
    
    [self.window setRootViewController:self.slidingVC];
    [self.window makeKeyAndVisible];
    
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
