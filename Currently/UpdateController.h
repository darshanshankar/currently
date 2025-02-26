//
//  UpdateController.h
//  Currently
//
//  Created by Darshan Shankar on 10/19/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonStatusTableViewController.h"
#import "SplashViewController.h"

@protocol StatusUpdatedProtocol <NSObject>
@required
- (void)statusHasUpdated;
@end

@interface UpdateController : UIViewController <CommonStatusProtocol, AuthenticationCompletionProtocol>

@property (nonatomic) id <StatusUpdatedProtocol>delegate;
@property (nonatomic, retain) UITextField *note;
@property (nonatomic, retain) NSString *activity;
@property (nonatomic, retain) NSString *location;

@end
