//
//  SplashViewController.m
//  Currently
//
//  Created by Darshan Shankar on 10/13/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "SplashViewController.h"
#import "LoginController.h"
#import "SignupController.h"
#import "StatusTableViewController.h"
#import "NetworkManager.h"
#import "InvitesTableViewController.h"
#import "SettingsTableViewController.h"
#import "NotificationsController.h"
#import "DataManager.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:@"accesstoken"]) {
        [self getLatestData];
    } else {
        NSLog(@"No accesstoken stored");
        [self displayLoginOrSignup];
    }
}

- (void)getLatestData {
    NetworkManager *manager = [NetworkManager getInstance];
    [manager getLatestDataWithCompletionHandler:^(int code, NSError *error, NSDictionary *data) {
        if(error == nil){
            NSLog(@"getLatestData OK %i", code);
            [self showStatusesWithData:data];
        } else if(code == 401 || error.code == -1012){
            NSLog(@"getLatestData error 401/-1012");
            [manager refreshTokensWithCompletionHandler:^(int refreshCode, NSError *refreshError) {
                if (refreshCode == 200) {
                    [self showStatusesWithData:data];
                } else {
                    [self displayLoginOrSignup];
                }
            }];
        } else {
            NSLog(@"getLatestData error");
            // what about non-authentication errors? server down etc.
            [self displayLoginOrSignup];
        }
    }];
}

- (void)showStatusesWithData:(NSDictionary *)data {
    StatusTableViewController *status = [[StatusTableViewController alloc] initWithData:data];
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:status];
    
    NSArray *friendRequests = [[data objectForKey:@"me"] objectForKey:@"requests"];
    InvitesTableViewController *pendingInvites = [[InvitesTableViewController alloc] initWithRequests:friendRequests];
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:pendingInvites];
    
    NotificationsController *notifications = [[NotificationsController alloc] init];
    UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:notifications];
    
    SettingsTableViewController *settings = [[SettingsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *nav4 = [[UINavigationController alloc] initWithRootViewController:settings];
    
    UITabBarController *tabBar = [[UITabBarController alloc] init];
    tabBar.viewControllers = [NSArray arrayWithObjects:nav1, nav2, nav3, nav4, nil];
    
    UIImage *feedImage = [UIImage imageNamed:@"feed"];
    UIImage *groupImage = [UIImage imageNamed:@"group"];
    UIImage *settingsImage = [UIImage imageNamed:@"settings"];
    UIImage *notificationsImage = [UIImage imageNamed:@"notifications"];
    
    UITabBarItem *statusItem = [[UITabBarItem alloc] initWithTitle:@"Feed" image:feedImage tag:1];
    UITabBarItem *pendingInvitesItem = [[UITabBarItem alloc] initWithTitle:@"Requests" image:groupImage tag:2];
    if(friendRequests.count > 0){
        [pendingInvitesItem setBadgeValue:[NSString stringWithFormat:@"%i", friendRequests.count]];
    }
    UITabBarItem *notificationsItem = [[UITabBarItem alloc] initWithTitle:@"Notifications" image:notificationsImage tag:3];
    UITabBarItem *settingsItem = [[UITabBarItem alloc] initWithTitle:@"Settings" image:settingsImage tag:4];
    
    [tabBar setToolbarItems:@[statusItem, pendingInvitesItem, notificationsItem, settingsItem]];
    [[UITabBar appearance] setTintColor:[UIColor grayColor]];
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor blackColor]];
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    
    nav1.tabBarItem = statusItem;
    nav2.tabBarItem = pendingInvitesItem;
    nav3.tabBarItem = notificationsItem;
    nav4.tabBarItem = settingsItem;
    
    DataManager *dataManager = [[DataManager alloc] initWithControllers:[NSArray arrayWithObjects:tabBar, status, pendingInvites, notifications, nil]];
    status.dataManager = dataManager;
    pendingInvites.dataManager = dataManager;

    [self presentViewController:tabBar animated:YES completion:nil];
}

- (void) displayLoginOrSignup {
    UIButton *login = [UIButton buttonWithType:UIButtonTypeCustom];
    [login setFrame:CGRectMake(0, 300, 320, 80)];
    [login setBackgroundColor:[UIColor greenColor]];
    [login setTitle:@"Log in" forState:UIControlStateNormal];
    [login addTarget:self action:@selector(showLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:login];
    
    UIButton *signup = [UIButton buttonWithType:UIButtonTypeCustom];
    [signup setFrame:CGRectMake(0, 400, 320, 80)];
    [signup setBackgroundColor:[UIColor blueColor]];
    [signup setTitle:@"Sign up" forState:UIControlStateNormal];
    [signup addTarget:self action:@selector(showSignup:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signup];
}

- (void)showLogin:(id)sender {
    LoginController *login = [[LoginController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:login];
    login.delegate = self;
    [self presentViewController:loginNav animated:YES completion:nil];
}

- (void)showSignup:(id)sender {
    SignupController *signup = [[SignupController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *signupNav = [[UINavigationController alloc] initWithRootViewController:signup];
    signup.delegate = self;
    [self presentViewController:signupNav animated:YES completion:nil];
}

- (void)successfulAuthentication {
    [self getLatestData];
}

@end
