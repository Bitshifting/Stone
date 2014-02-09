//
//  LeftViewController.h
//  Stone
//
//  Created by Kenneth Siu on 2/8/14.
//  Copyright (c) 2014 Kenneth Siu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftViewController : UIViewController  <UITableViewDelegate, UITableViewDataSource>

@property UITableView *table;
@property NSMutableArray *arrOfFriends;

@end
