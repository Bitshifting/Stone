//
//  LeftViewController.h
//  Stone
//
//  Created by Kenneth Siu on 2/8/14.
//  Copyright (c) 2014 Kenneth Siu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface LeftViewController : UIViewController  <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property (strong, nonatomic) UITableView *table;
@property (strong, nonatomic) NSMutableArray *arrOfFriends;
@property (strong, nonatomic) UIAlertView *addFriend;
@property (strong, nonatomic) UIAlertView *removeFriend;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *uid;
@property (weak, nonatomic) ViewController *viewCont;

- (void) reloadFriends;

@end
