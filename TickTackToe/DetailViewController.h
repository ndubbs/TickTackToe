//
//  DetailViewController.h
//  TickTackToe
//
//  Created by Nicholas Waynik on 4/16/12.
//  Copyright (c) 2012 Fresh App Factory. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "GCHelper.h"

@interface DetailViewController : UIViewController <GCHelperDelegate>

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIButton *button1;
@property (nonatomic, strong) IBOutlet UIButton *button2;
@property (nonatomic, strong) IBOutlet UIButton *button3;
@property (nonatomic, strong) IBOutlet UIButton *button4;
@property (nonatomic, strong) IBOutlet UIButton *button5;
@property (nonatomic, strong) IBOutlet UIButton *button6;
@property (nonatomic, strong) IBOutlet UIButton *button7;
@property (nonatomic, strong) IBOutlet UIButton *button8;
@property (nonatomic, strong) IBOutlet UIButton *button9;
@property (nonatomic, strong) IBOutlet UIButton *resignButton;
@property (nonatomic, strong) GKTurnBasedMatch *match;
@property (nonatomic, strong) NSString *myPlayerCharacter;
@property (nonatomic, strong) NSMutableDictionary *gameDictionary;
@property (nonatomic, strong) GCHelper *gcHelper;
@property (nonatomic, retain) IBOutletCollection(UIButton) NSArray *buttonCollection;

- (IBAction)quitGame:(id)sender;
- (IBAction)playTurn:(id)sender;
- (NSString *)checkWinner;
- (void)populateExistingGameBoard;
- (void)setButtonEnabled:(BOOL)enabled;

@end
