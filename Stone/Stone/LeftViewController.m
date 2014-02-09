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
#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "Friend.h"
#import "MBProgressHUD.h"

@interface LeftViewController ()
@property (weak) ViewController *vCont;
@end

@implementation LeftViewController {
}

@synthesize table, arrOfFriends, addFriend, removeFriend;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _vCont = (ViewController*)[((UINavigationController*)self.slidingViewController.topViewController).viewControllers objectAtIndex:0];
        arrOfFriends = [[NSMutableArray alloc] init];
        UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        // Custom initialization
        table = [[UITableView alloc] initWithFrame:CGRectMake(0, 16, [[UIScreen mainScreen] bounds].size.width - 100,[[UIScreen mainScreen] bounds].size.height - 70) style:UITableViewStylePlain];
        
        
        //table.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 50, [[UIScreen mainScreen] bounds].size.width - 100, 50)];
        [button setTitle:@"Add Follower" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:1.0]];
        [button addTarget:self action:@selector(addFriendAlert) forControlEvents:UIControlEventTouchDown];
        [view addSubview:table];
        [view addSubview:button];
        
        [table setBackgroundColor:[UIColor clearColor]];
        
        table.delegate = self;
        table.dataSource = self;
        
        self.view = view;
    }
    return self;
}

- (void) addFriendAlert {
    //set alert so one can type in friend's name
    addFriend = [[UIAlertView alloc] initWithTitle:@"Add Friend" message:@"Friend Name:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK" , nil];
    addFriend.alertViewStyle = UIAlertViewStylePlainTextInput;
    [addFriend show];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if([alertView isEqual:addFriend]) {
        if(buttonIndex == 0) {
            return;
        }
        
        NSString *frDispName =[alertView textFieldAtIndex:0].text;
        BOOL alreadyFriend = NO;
        
        for(Friend *fr in arrOfFriends) {
            if([fr.displayName isEqualToString:frDispName]) {
                alreadyFriend = YES;
                break;
            }
        }
        
        if(alreadyFriend) {
            return;
        }
        
        //if not already a friend, begin to add friend
        NSData *data = [API addFriend:_vCont.url uid:_vCont.uid displayName:_vCont.profileName];
        
        if(data != nil) {
            NSError* error;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:kNilOptions
                                  error:&error];
            
            if([(NSNumber*)[json objectForKey:@"success"] isEqualToNumber:[NSNumber numberWithInt:1]]) {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                
                // Configure for text only and offset down
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"Added Follower!";
                hud.margin = 10.f;
                hud.yOffset = 150.f;
                hud.removeFromSuperViewOnHide = YES;
                
                [hud hide:YES afterDelay:2];
                
                //refresh friends
                [self reloadFriends];
                
                
            }
        }
        
        return;
        
        
    } else if([alertView isEqual:removeFriend]) {
        if(buttonIndex == 0) {
            return;
        }
        
        //time to remove friend
        NSData *data = [API delFriend:_vCont.url uid:_vCont.uid displayName:_vCont.profileName];
        
        if(data != nil) {
            NSError* error;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:kNilOptions
                                  error:&error];
            
            if([(NSNumber*)[json objectForKey:@"success"] isEqualToNumber:[NSNumber numberWithInt:1]]) {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                
                // Configure for text only and offset down
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"Removed Follower!";
                hud.margin = 10.f;
                hud.yOffset = 150.f;
                hud.removeFromSuperViewOnHide = YES;
                
                [hud hide:YES afterDelay:2];
                
                //refresh friends
                [self reloadFriends];
                
                
            }
        }
        
        return;
    }
}

//table view delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrOfFriends count];
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
    
    NSLog(@"%i", indexPath.row);
    
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

- (void) reloadFriends {
    //clear all friends
    [self.arrOfFriends removeAllObjects];
    
    //grab friends
    NSData *data = [API getFriends:_vCont.url uid:_vCont.uid];
    
    if(data != nil) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:data
                              options:kNilOptions
                              error:&error];
        
        for(NSDictionary *dict in json) {
            Friend *tempFr = [[Friend alloc] initWithID:(NSString*)[dict objectForKey:@"_id"] displayName:(NSString*)[dict objectForKey:@"username"]];
            [self.arrOfFriends addObject:tempFr];
        }
    }
    
    [self.table reloadData];
}

@end
