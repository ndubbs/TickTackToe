//
//  MenuViewController.m
//  TickTackToe
//
//  Created by Nicholas Waynik on 4/17/12.
//  Copyright (c) 2012 Fresh App Factory. All rights reserved.
//

#import "MenuViewController.h"
#import "DetailViewController.h"

@implementation MenuViewController

@synthesize detailViewController;
@synthesize gcHelper;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Tick Tack Toe", @"Tick Tack Toe");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setGcHelper:[GCHelper sharedInstance]];
    [self.gcHelper setMenuDelegate:self];
    [self.gcHelper authenticateLocalUser];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - IBActions

- (IBAction)createNewMatch:(id)sender
{
    if (self.gcHelper.userAuthenticated) {
        
        [self.gcHelper showMatchmakerViewControllerWithMinPlayers:2 maxPlayers:2 viewController:self showExistingMatches:NO];
        
    } else {
        [self showGameCenterLoginError];
    }
}

- (IBAction)viewExsitingMatches:(id)sender
{
    if (self.gcHelper.userAuthenticated) {

        [self.gcHelper showMatchmakerViewControllerWithMinPlayers:2 maxPlayers:2 viewController:self showExistingMatches:YES];
        
    } else {
        [self showGameCenterLoginError];
    }
}

- (void)showGameCenterLoginError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Not Logged In", @"Error title for user not logged in to Apple Game Center") message:NSLocalizedString(@"You are not logged in to Game Center, please log in and try again.", @"Error message informing the player to log in to Apple Game Center and try again.") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
    [alert show];
}


#pragma mark - GCMenuHelperDelegate

- (void)startGCGameWithMatch:(GKTurnBasedMatch *)theMatch
{
    DetailViewController *gameViewController = [[DetailViewController alloc] init];
    [gameViewController setMatch:theMatch];
    [self.navigationController pushViewController:gameViewController animated:YES];
}

@end
