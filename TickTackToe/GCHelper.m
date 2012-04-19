//
//  GCHelperDelegate.m
//  TickTackToe
//
//  Created by Nicholas Waynik on 4/16/12.
//  Copyright (c) 2012 Fresh App Factory. All rights reserved.
//

#import "GCHelper.h"

@implementation GCHelper 

@synthesize gameCenterAvailable;
@synthesize userAuthenticated;
@synthesize isGameVisible;
@synthesize currentMatch;
@synthesize localPlayer;
@synthesize presentingViewController;
@synthesize delegate;
@synthesize menuDelegate;


static GCHelper *sharedHelper = nil;
+ (GCHelper *) sharedInstance 
{
    if (!sharedHelper) {
        sharedHelper = [[GCHelper alloc] init];
    }
    return sharedHelper;
}

+ (GKLocalPlayer *)getLocalPlayer 
{
    return [GKLocalPlayer localPlayer];
}

- (id)init 
{
    if ((self = [super init])) {
        gameCenterAvailable = [self isGameCenterAvailable];
        if (gameCenterAvailable) {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc addObserver:self selector:@selector(authenticationChanged) 
                       name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
        }
    }
    return self;
}


#pragma mark - User functions

- (BOOL)isGameCenterAvailable 
{
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

- (void)authenticationChanged 
{    
    if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated) {
        userAuthenticated = YES;           
    } else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated) {
        userAuthenticated = NO;
    }
}

- (void)authenticateLocalUser 
{     
    if (!gameCenterAvailable) return;
    
    void (^setGKEventHandlerDelegate)(NSError *) = ^ (NSError *error){
        GKTurnBasedEventHandler *ev = [GKTurnBasedEventHandler sharedTurnBasedEventHandler];
        ev.delegate = self;
    };
    
    if ([GKLocalPlayer localPlayer].authenticated == NO) {     
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:setGKEventHandlerDelegate];   
        self.localPlayer = [GKLocalPlayer localPlayer];
    } else {
        setGKEventHandlerDelegate(nil);
    }
}


#pragma mark -

- (void)showMatchmakerViewControllerWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers viewController:(UIViewController *)viewController showExistingMatches:(BOOL)showMatches
{
    if (!gameCenterAvailable) return;
    
    self.presentingViewController = viewController;              
    GKMatchRequest *matchRequest = [[GKMatchRequest alloc] init]; 
    matchRequest.minPlayers = minPlayers;     
    matchRequest.maxPlayers = maxPlayers;
    
    GKTurnBasedMatchmakerViewController *mmvc = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:matchRequest];    
    mmvc.turnBasedMatchmakerDelegate = self;
    
    mmvc.showExistingMatches = showMatches;
    
    [presentingViewController presentModalViewController:mmvc animated:YES];
}


#pragma mark - GKTurnBasedMatchmakerViewControllerDelegate

// The user has cancelled matchmaking
- (void)turnBasedMatchmakerViewControllerWasCancelled:(GKTurnBasedMatchmakerViewController *)viewController 
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

// Matchmaking has failed with an error
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFailWithError:(NSError *)error 
{
    //handle error
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The Internet connection appears to be offline." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

// Quiting a match from the GKTurnBasedMatchmakerViewController
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController playerQuitForMatch:(GKTurnBasedMatch *)theMatch 
{    
    // Check to see if local player is current participant
    GKTurnBasedParticipant *nextParticipant = [self getNextParticipantWithMatch:theMatch];
    NSString *currentPlayerID = theMatch.currentParticipant.playerID;
    if ([currentPlayerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
        
        [theMatch participantQuitInTurnWithOutcome:GKTurnBasedMatchOutcomeQuit nextParticipant:nextParticipant matchData:theMatch.matchData completionHandler:^(NSError*error){
            
        }];
    } else {
        [theMatch participantQuitOutOfTurnWithOutcome:GKTurnBasedMatchOutcomeQuit withCompletionHandler:^(NSError*error){
            
        }];
    }
}

// A match has been found, the game should start
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFindMatch:(GKTurnBasedMatch *)theMatch 
{
    self.presentingViewController = viewController;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil]; 
    
    self.currentMatch = theMatch;
    [self.menuDelegate startGCGameWithMatch:theMatch];
}


#pragma mark - GKTurnBasedEventHandlerDelegate

- (void)handleInviteFromGameCenter:(NSArray *)playersToInvite 
{
    //Sent to the delegate when the local player receives an invitation to join a new turn-based match.
    /*
     When your delegate receives this message, your application should create a new 
     GKMatchRequest object and assign the playersToInvite parameter to the match request’s 
     playersToInvite property. Then, your application can either call the GKTurnBasedMatch 
     class method findMatchForRequest:withCompletionHandler: to find a match programmatically 
     or it can use the request to instantiate a new GKTurnBasedMatchmakerViewController to 
     show a user interface to the player.
     */
    
    [presentingViewController dismissModalViewControllerAnimated:YES];
    GKMatchRequest *matchRequest = [[GKMatchRequest alloc] init]; 
    matchRequest.playersToInvite = playersToInvite;
    matchRequest.minPlayers = 2;     
    matchRequest.maxPlayers = 2;
    
    GKTurnBasedMatchmakerViewController *mmvc = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:matchRequest];
    mmvc.showExistingMatches = NO;
    mmvc.turnBasedMatchmakerDelegate = self;
    
  
    // Display Matchmaker view controller which will have the invite in the list of current matches
}

- (void)handleTurnEventForMatch:(GKTurnBasedMatch *)theMatch 
{
    //Sent to the delegate when it is the local player’s turn to act in a turn-based match.
    
    /*
     When your delegate receives this message, the player has accepted a push notification for 
     a match already in progress. Your game should end whatever task it was performing and 
     switch to the match information provided by the match object. For more information on 
     handling player actions in a turn-based match, see GKTurnBasedMatch Class Reference.
     */

    if (self.isGameVisible && [theMatch.matchID isEqualToString:currentMatch.matchID]) {
        self.currentMatch = theMatch;
        
        if ([self opponentDidEndMatch:theMatch]) {
            // This case is for when the other player quit the match in turn
            [self submitEndForMatch:theMatch withData:theMatch.matchData winner:YES endType:1 withMessage:@"Game Over"];
            return;
            
        } else if (theMatch.currentParticipant.status == GKTurnBasedParticipantStatusDeclined) {
            
            // Other player declined the game invite
            for (GKTurnBasedParticipant *participant in theMatch.participants) {
                if (participant.status == GKTurnBasedParticipantStatusDeclined) {
                    [self endMatchForDecline:theMatch];
                    return;
                }             
            }
        }
        
        if ([theMatch.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            // Update UI and allow turn submission
            [delegate startTurnWithMatch:theMatch];
        } 
    }
}

- (void)handleMatchEnded:(GKTurnBasedMatch *)theMatch 
{
    //Sent to the delegate when a match the local player is participating in has ended.
    
    /*
     When your delegate receives this message, it should display the match’s final results to
     the player and allow the player the option of saving or removing the match data from 
     Game Center.
     */
    
    if (self.isGameVisible && [theMatch.matchID isEqualToString:currentMatch.matchID]) {
        currentMatch = theMatch;
        BOOL isResign = NO;
        
        // Opponent ended the current match
        for (GKTurnBasedParticipant *participant in theMatch.participants) {
            if (participant.matchOutcome == GKTurnBasedMatchOutcomeQuit) {
                isResign = YES;
                break;
            }
        }
        
        if (isResign) {
            [delegate endGame:theMatch forResign:YES];
        } else {
            [delegate endGame:theMatch forResign:NO];
        }
    }    
}

#pragma mark - 

- (void)submitTurnForMatch:(GKTurnBasedMatch *)theMatch withData:(NSData *)turnData withMessage:(NSString *)turnMessage 
{
    if(theMatch != nil) {
        
        GKTurnBasedParticipant *nextParticipant = [self getNextParticipantWithMatch:theMatch];
        theMatch.message = turnMessage;
        [theMatch endTurnWithNextParticipant:nextParticipant matchData:turnData completionHandler:^(NSError *error){
            if(error == nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate turnSubmissionDidSucceed:theMatch];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate turnSubmissionDidFail:theMatch];
                });
            }
        }];   
        
    } 
}

- (void)submitEndForMatch:(GKTurnBasedMatch *)theMatch withData:(NSData *)turnData winner:(BOOL)localWon endType:(int)endType withMessage:(NSString *)turnMessage 
{
    // Set the participants match outcome status
    for (GKTurnBasedParticipant *participant in theMatch.participants) {
        if (endType == 1) {
            // Won/Lost end type
            if ([participant.playerID isEqualToString:[self localPlayer].playerID]) {
                if (localWon) {
                    participant.matchOutcome = GKTurnBasedMatchOutcomeWon;
                } else {
                    participant.matchOutcome = GKTurnBasedMatchOutcomeLost;
                }
            } else {
                if (localWon) {
                    participant.matchOutcome = GKTurnBasedMatchOutcomeLost;
                } else {
                    participant.matchOutcome = GKTurnBasedMatchOutcomeWon;
                }
            }
        } else {
            // Draw end type
            participant.matchOutcome = GKTurnBasedMatchOutcomeTied;
        }
    }
    
    // Set the match message
    theMatch.message = turnMessage;
    
    [theMatch endMatchInTurnWithMatchData:turnData completionHandler:^(NSError *error) {
        if(error == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [delegate matchDidEnd:theMatch];
                
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate turnSubmissionDidFail:theMatch];
            });
        }
    }];           
}

- (void)quitMatchOutOfTurn:(GKTurnBasedMatch *)theMatch 
{
    for (GKTurnBasedParticipant *participant in theMatch.participants) {
        if ([participant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            participant.matchOutcome = GKTurnBasedMatchOutcomeQuit;
        } else {
            participant.matchOutcome = GKTurnBasedMatchOutcomeWon;
        }
    }
    
    [theMatch participantQuitOutOfTurnWithOutcome:GKTurnBasedMatchOutcomeQuit withCompletionHandler:^(NSError *error) {
        if (error == nil) {
            [delegate resignDidSucceed:theMatch];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate resignDidFail:theMatch];
            });
        }
    }];    
}

- (void)endMatchForDecline:(GKTurnBasedMatch *)theMatch 
{
    // set participant matchOutcomes
    for (GKTurnBasedParticipant *participant in theMatch.participants) {
        
        if ([participant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            participant.matchOutcome = GKTurnBasedMatchOutcomeNone;            
        } else {
            participant.matchOutcome = GKTurnBasedMatchOutcomeNone;
        }
    }
    
    NSString *alertText = [NSString stringWithFormat:@"%@", NSLocalizedString(@"The opponent has declined the match!", @"The opponent has declined the match!"), theMatch.currentParticipant.playerID];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Game Over", @"Title text: Game Over") message:alertText delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil, nil];
    alert.tag = 1;
    [alert show];
    
    if ([currentMatch.matchID isEqualToString:theMatch.matchID]) {
        [delegate endGameForDecline:theMatch];
    }
}




















- (GKTurnBasedParticipant *)getNextParticipantWithMatch:(GKTurnBasedMatch *)theMatch
{
    // Figure out the next participant
    GKTurnBasedParticipant *part1 = [theMatch.participants objectAtIndex:0];
    GKTurnBasedParticipant *part2 = [theMatch.participants objectAtIndex:1];
    GKTurnBasedParticipant *nextParticipant = nil;
    
    if([theMatch.currentParticipant.playerID isEqualToString:part1.playerID]) {
        nextParticipant = part2;
    } else {
        nextParticipant = part1;
    }
    
    return nextParticipant;
}

- (BOOL)isLocalPlayersTurnForMatch:(GKTurnBasedMatch *)theMatch 
{
    if([theMatch.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
        return YES;
    } 
    
    return NO;
}

- (BOOL)opponentDidEndMatch:(GKTurnBasedMatch *)theMatch
{
    for (GKTurnBasedParticipant *participant in theMatch.participants) {
        if (participant.status == GKTurnBasedParticipantStatusDone) {
            return YES;
        } else if (participant.status == GKTurnBasedParticipantStatusDeclined) {
            return YES;
        }
    }
    
    return NO;
}

@end
