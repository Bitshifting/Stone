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
#import "Friend.h"
#import "MBProgressHUD.h"

@interface LeftViewController ()
@end

@implementation LeftViewController {
    NSString *tempName;
    MBProgressHUD *HUD;
}

@synthesize table, arrOfFriends, addFriend, removeFriend, uid, url, viewCont;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        arrOfFriends = [[NSMutableArray alloc] init];
        UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        // Custom initialization
        table = [[UITableView alloc] initWithFrame:CGRectMake(0, 16, [[UIScreen mainScreen] bounds].size.width - 100,[[UIScreen mainScreen] bounds].size.height - 70) style:UITableViewStylePlain];
        
        
        //table.separatorStyle = UITableViewCellSeparatorStyleNone;
        [table setSeparatorInset:UIEdgeInsetsZero];
        
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 50, [[UIScreen mainScreen] bounds].size.width - 100, 50)];
        [button setTitle:@"Add Friend" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:1.0]];
        [button addTarget:self action:@selector(addFriendAlert) forControlEvents:UIControlEventTouchDown];
        [view addSubview:table];
        [view addSubview:button];
        
        [table setBackgroundColor:[UIColor clearColor]];
        
        table.delegate = self;
        table.dataSource = self;
        
        self.view = view;
        HUD = [[MBProgressHUD alloc] initWithView:table];
        [self.view addSubview:HUD];
    }
    return self;
}

- (void) addFriendAlert {
    //set alert so one can type in friend's name
    addFriend = [[UIAlertView alloc] initWithTitle:@"Add Friend" message:@"Friend Name:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK" , nil];
    addFriend.alertViewStyle = UIAlertViewStylePlainTextInput;
    [addFriend show];
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
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            // Configure for text only and offset down
            HUD.mode = MBProgressHUDModeText;
            HUD.labelText = @"Already your friend!";
            HUD.margin = 10.f;
            HUD.yOffset = 150.f;
            HUD.removeFromSuperViewOnHide = YES;
            
            [HUD hide:YES afterDelay:2];
            return;
        }
        
        //if not already a friend, begin to add friend
        NSData *data = [API addFriend:[ViewController parseSpace:url] uid:uid displayName:[ViewController parseSpace:frDispName]];
        
        if(data != nil) {
            NSError* error;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:kNilOptions
                                  error:&error];
            
            if([(NSNumber*)[json objectForKey:@"success"] isEqualToNumber:[NSNumber numberWithInt:1]]) {
                HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                
                // Configure for text only and offset down
                HUD.mode = MBProgressHUDModeText;
                HUD.labelText = @"Added Friend!";
                HUD.margin = 10.f;
                HUD.yOffset = 150.f;
                HUD.removeFromSuperViewOnHide = YES;
                
                [HUD hide:YES afterDelay:2];
                
                //refresh friends
                [self reloadFriends];
                
                
            }
        } else {
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            // Configure for text only and offset down
            HUD.mode = MBProgressHUDModeText;
            HUD.labelText = @"User does not exist!";
            HUD.margin = 10.f;
            HUD.yOffset = 150.f;
            HUD.removeFromSuperViewOnHide = YES;
            
            [HUD hide:YES afterDelay:2];
            
            //refresh friends
            [self reloadFriends];
        }
        
        return;
        
        
    } else if([alertView isEqual:removeFriend]) {
        if(buttonIndex == 0) {
            return;
        }
        
        //time to remove friend
        NSData *data = [API delFriend:[ViewController parseSpace:url] uid:uid displayName:[ViewController parseSpace:tempName]];
        
        if(data != nil) {
            NSError* error;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:kNilOptions
                                  error:&error];
            
            if([(NSNumber*)[json objectForKey:@"success"] isEqualToNumber:[NSNumber numberWithInt:1]]) {
                HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                
                // Configure for text only and offset down
                HUD.mode = MBProgressHUDModeText;
                HUD.labelText = @"Removed Friend!";
                HUD.margin = 10.f;
                HUD.yOffset = 150.f;
                HUD.removeFromSuperViewOnHide = YES;
                
                [HUD hide:YES afterDelay:2];
                
                //refresh friends
                [self reloadFriends];
                
                tempName = nil;
                
                
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
    
    tempName = ((Friend*)[arrOfFriends objectAtIndex:indexPath.row]).displayName;
    
    //set alert so one can type in friend's name
    removeFriend = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Remove Friend: %@", tempName] message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes" , nil];
    [removeFriend show];
    
    
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
    NSData *data = [API getFriends:[ViewController parseSpace:url] uid:uid];
    
    if(data != nil) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:data
                              options:kNilOptions
                              error:&error];
        
        for(NSDictionary *dict in json) {
            Friend *tempFr = [[Friend alloc] initWithID:(NSString*)[dict objectForKey:@"followee"] displayName:(NSString*)[dict objectForKey:@"followeeName"]];
            [self.arrOfFriends addObject:tempFr];
        }
    }
    
    [self.table reloadData];
}

@end
