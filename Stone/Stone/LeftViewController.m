//
//  LeftViewController.m
//  Stone
//
//  Created by Kenneth Siu on 2/8/14.
//  Copyright (c) 2014 Kenneth Siu. All rights reserved.
//

#import "LeftViewController.h"
#import "ViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "Friend.h"

@interface LeftViewController ()
@end

@implementation LeftViewController {
}

@synthesize table, arrOfFriends;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        arrOfFriends = [[NSMutableArray alloc] init];
        
        // Custom initialization
        table = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStylePlain];
        
        table.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        table.delegate = self;
        table.dataSource = self;
        
        //set the map as highlighted
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection: 0];
        
        [table selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        
        self.view = table;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

//table view delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrOfFriends count];
}

- (void) viewDidLayoutSubviews {
    // only works for iOS 7+
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        CGRect viewBounds = self.view.bounds;
        CGFloat topBarOffset = self.topLayoutGuide.length;
        
        // snaps the view under the status bar (iOS 6 style)
        viewBounds.origin.y = topBarOffset * -2;
        
        // shrink the bounds of your view to compensate for the offset
        viewBounds.size.height = viewBounds.size.height + (topBarOffset * -2);
        self.view.bounds = viewBounds;
        self.view.backgroundColor = [UIColor whiteColor];
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = ((Friend*)[arrOfFriends objectAtIndex:indexPath.row]).displayName;
    
    return cell;
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    
    UINavigationController *nav  = (UINavigationController*)self.slidingViewController.topViewController;
    
    //get main view controller (the top one)
    ViewController *view = (ViewController*)[nav.viewControllers objectAtIndex:0];
    
    //if clicking map, set it to map
    if(indexPath.row == 0) {
        [view changeToMap];
    }
    //if clicking settings, go to settings
    if(indexPath.row == 1) {
        [view changeToSettings];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (void)anchorLeft {
    
    ECSlidingViewControllerTopViewPosition pos = self.slidingViewController.currentTopViewPosition;
    
    if(pos == 2) {
        [self.slidingViewController anchorTopViewToRightAnimated:YES];
    } else {
        [self.slidingViewController resetTopViewAnimated:YES];
    }
}

@end
