//
//  MenuViewController.h
//  TickTackToe
//
//  Created by Nicholas Waynik on 4/17/12.
//  Copyright (c) 2012 Fresh App Factory. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"
#import "GCHelper.h"

@interface MenuViewController : UIViewController <GCMenuHelperDelegate>

@property (nonatomic, strong) DetailViewController *detailViewController;
@property (nonatomic, strong) GCHelper *gcHelper;

- (IBAction)createNewMatch:(id)sender;
- (IBAction)viewExsitingMatches:(id)sender;
- (void)showGameCenterLoginError;

@end
