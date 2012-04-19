//
//  GCHelper.h
//  TickTackToe
//
//  Created by Nicholas Waynik on 4/16/12.
//  Copyright (c) 2012 Fresh App Factory. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@class GCHelper;

@protocol GCMenuHelperDelegate <NSObject>

@optional

- (void)startGCGameWithMatch:(GKTurnBasedMatch *)theMatch;

@end



@protocol GCHelperDelegate <NSObject>

- (void)turnSubmissionDidSucceed:(GKTurnBasedMatch *)theMatch;
- (void)turnSubmissionDidFail:(GKTurnBasedMatch *)theMatch;
- (void)startTurnWithMatch:(GKTurnBasedMatch *)theMatch;
- (void)matchDidEnd:(GKTurnBasedMatch *)theMatch;
- (void)resignDidSucceed:(GKTurnBasedMatch *)theMatch;
- (void)resignDidFail:(GKTurnBasedMatch *)theMatch;
- (void)endGameForDecline:(GKTurnBasedMatch *)theMatch;
- (void)endGame:(GKTurnBasedMatch *)theMatch forResign:(BOOL)didResign;

@end



@interface GCHelper : NSObject <GKTurnBasedMatchmakerViewControllerDelegate,GKTurnBasedEventHandlerDelegate>

@property (assign, readonly) BOOL gameCenterAvailable;
@property (assign, readonly) BOOL userAuthenticated;
@property (nonatomic, assign) BOOL isGameVisible;
@property (nonatomic, strong) GKTurnBasedMatch *currentMatch;
@property (nonatomic, strong) GKLocalPlayer *localPlayer;
@property (retain) UIViewController *presentingViewController;
@property (assign) id <GCHelperDelegate> delegate;
@property (assign) id <GCMenuHelperDelegate> menuDelegate;

+ (GCHelper *)sharedInstance;
+ (GKLocalPlayer *)getLocalPlayer;
- (void)authenticationChanged;
- (void)authenticateLocalUser;

- (void)showMatchmakerViewControllerWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers viewController:(UIViewController *)viewController showExistingMatches:(BOOL)showMatches;

- (void)submitTurnForMatch:(GKTurnBasedMatch *)theMatch withData:(NSData *)turnData withMessage:(NSString *)turnMessage;
- (void)submitEndForMatch:(GKTurnBasedMatch *)theMatch withData:(NSData *)turnData winner:(BOOL)localWon endType:(int)endType withMessage:(NSString *)turnMessage;
- (void)quitMatchOutOfTurn:(GKTurnBasedMatch *)theMatch;
- (void)endMatchForDecline:(GKTurnBasedMatch *)theMatch;

- (GKTurnBasedParticipant *)getNextParticipantWithMatch:(GKTurnBasedMatch *)theMatch;
- (BOOL)isLocalPlayersTurnForMatch:(GKTurnBasedMatch *)theMatch;
- (BOOL)opponentDidEndMatch:(GKTurnBasedMatch *)theMatch;



@end
