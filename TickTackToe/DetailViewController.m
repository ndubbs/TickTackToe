//
//  DetailViewController.m
//  TickTackToe
//
//  Created by Nicholas Waynik on 4/16/12.
//  Copyright (c) 2012 Fresh App Factory. All rights reserved.
//

#import "DetailViewController.h"

@implementation DetailViewController

@synthesize titleLabel;
@synthesize button1;
@synthesize button2;
@synthesize button3;
@synthesize button4;
@synthesize button5;
@synthesize button6;
@synthesize button7;
@synthesize button8;
@synthesize button9;
@synthesize resignButton;
@synthesize match;
@synthesize myPlayerCharacter;
@synthesize gameDictionary;
@synthesize gcHelper;
@synthesize buttonCollection;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.gameDictionary = [[NSMutableDictionary alloc] init];
    [self setGcHelper:[GCHelper sharedInstance]];
    [self.gcHelper setDelegate:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [gcHelper setIsGameVisible:YES];
    
    // Set the title label
    if (self.match.currentParticipant == [self.match.participants objectAtIndex:0]) {
        self.myPlayerCharacter = @"X";
        self.titleLabel.text = @"It is X's Turn";
    } else {
        self.myPlayerCharacter = @"O";
        self.titleLabel.text = @"It is O's Turn";
    }
    
    // Configure the game board
    NSDictionary *myDict = [NSPropertyListSerialization propertyListFromData:self.match.matchData mutabilityOption:NSPropertyListImmutable format:nil errorDescription:nil];
    
    [self.gameDictionary addEntriesFromDictionary: myDict];         
    [self populateExistingGameBoard];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [gcHelper setIsGameVisible:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Game", @"Game");
    }
    return self;
}


#pragma mark - IBActions

- (IBAction)quitGame:(id)sender
{
    // Check to see if it is the local player's turn and call the appropriate method to end the match
    BOOL isLocalPlayersTurn = [self.gcHelper isLocalPlayersTurnForMatch:self.match];

    if (isLocalPlayersTurn) {
        [self.gcHelper submitEndForMatch:self.match withData:self.match.matchData winner:NO endType:1 withMessage:@"Player Quit"];
    } else {
        [self.gcHelper quitMatchOutOfTurn:self.match];
    }
}

- (IBAction)playTurn:(id)sender
{
    [(UIButton *)sender setTitle:self.myPlayerCharacter forState:UIControlStateNormal];
    
    NSString *buttonIndexString = [NSString stringWithFormat:@"%d", [(UIButton *)sender tag]];
    [self.gameDictionary setObject:self.myPlayerCharacter forKey:buttonIndexString];
    
    NSData *data = [NSPropertyListSerialization dataFromPropertyList:self.gameDictionary format:NSPropertyListXMLFormat_v1_0 errorDescription:nil];
    
    NSString *matchOutcome = [self checkWinner];
    
    if (matchOutcome != nil) {
        
        NSString *matchMessage;
        
        if ([matchOutcome isEqualToString:@"Tied"]) {
            matchMessage = @"Game is a tie!";
        } else {
            matchMessage = [NSString stringWithFormat:@"%@ won!", matchOutcome];
        }
        
        [self.gcHelper submitEndForMatch:self.match withData:data winner:[self.myPlayerCharacter isEqualToString:matchOutcome] endType:1 withMessage:matchMessage];

    } else {  
        
        [self.gcHelper submitTurnForMatch:self.match withData:data withMessage:@"Turn was played"];
        
    } 
}

- (NSString *)checkWinner
{
    //top row
    if ([self.button1.titleLabel.text isEqualToString:self.button2.titleLabel.text] && [self.button2.titleLabel.text isEqualToString:self.button3.titleLabel.text])
        return self.button1.titleLabel.text;
    //middle row
    if ([self.button4.titleLabel.text isEqualToString:self.button5.titleLabel.text] && [self.button5.titleLabel.text isEqualToString:self.button6.titleLabel.text])
        return self.button4.titleLabel.text;
    //bottom row
    if ([self.button7.titleLabel.text isEqualToString:self.button8.titleLabel.text] && [self.button8.titleLabel.text isEqualToString:self.button9.titleLabel.text])
        return self.button7.titleLabel.text; 
    
    //first column
    if ([self.button1.titleLabel.text isEqualToString:self.button4.titleLabel.text] && [self.button4.titleLabel.text isEqualToString:self.button7.titleLabel.text])
        return self.button1.titleLabel.text;
    //middle column
    if ([self.button2.titleLabel.text isEqualToString:self.button5.titleLabel.text] && [self.button5.titleLabel.text isEqualToString:self.button8.titleLabel.text])
        return self.button2.titleLabel.text;
    //last column
    if ([self.button3.titleLabel.text isEqualToString:self.button6.titleLabel.text] && [self.button6.titleLabel.text isEqualToString:self.button9.titleLabel.text])
        return self.button3.titleLabel.text;
    
    //diagonal
    if ([self.button1.titleLabel.text isEqualToString:self.button5.titleLabel.text] && [self.button5.titleLabel.text isEqualToString:self.button9.titleLabel.text])
        return self.button1.titleLabel.text;
    if ([self.button3.titleLabel.text isEqualToString:self.button5.titleLabel.text] && [self.button5.titleLabel.text isEqualToString:self.button7.titleLabel.text])
        return self.button3.titleLabel.text;
    
    
    if (self.button1.titleLabel.text != nil && self.button2.titleLabel.text != nil && self.button3.titleLabel.text != nil &&
        self.button4.titleLabel.text != nil && self.button5.titleLabel.text != nil && self.button6.titleLabel.text != nil &&
        self.button7.titleLabel.text != nil && self.button8.titleLabel.text != nil && self.button9.titleLabel.text != nil) {
        
        return @"Tie";
    }
    
    return nil;
}

- (void)populateExistingGameBoard
{
    NSArray *dataArray = [self.gameDictionary allKeys];
    
    for (NSString *key in dataArray) {
        for (UIButton *aButton in self.buttonCollection) {
            if (aButton.tag == [key intValue]) {
                [aButton setTitle:[self.gameDictionary objectForKey:key] forState:UIControlStateNormal];
                [aButton setEnabled: NO];
                break;
            }
        }
    }
}

- (void)setButtonEnabled:(BOOL)enabled
{
    for (UIButton *aButton in self.buttonCollection) {
        [aButton setEnabled:enabled];
    }
}


#pragma mark - GCHelperDelegate

- (void)turnSubmissionDidSucceed:(GKTurnBasedMatch *)theMatch
{
    if ([self.myPlayerCharacter isEqualToString:@"X"]) {
        self.titleLabel.text = @"It is O's Turn";
    } else {
        self.titleLabel.text = @"It is X's Turn";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Turn Submitted" message:@"Your turn submission was successful!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)turnSubmissionDidFail:(GKTurnBasedMatch *)theMatch
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Submission Failed" message:@"Your turn submission failed!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    
    [self setButtonEnabled:YES];
}

- (void)startTurnWithMatch:(GKTurnBasedMatch *)theMatch
{
    self.titleLabel.text = [NSString stringWithFormat:@"It is %@'s Turn", self.myPlayerCharacter];
    
    NSPropertyListFormat plf = 1;
    NSError *error;
    self.gameDictionary = [NSPropertyListSerialization propertyListWithData:theMatch.matchData options:0 format:&plf error:&error];
	
    // Update the game board
    [self setMatch:theMatch];
    [self populateExistingGameBoard];
    
    [self setButtonEnabled:YES];
}

- (void)matchDidEnd:(GKTurnBasedMatch *)theMatch
{
    [self setButtonEnabled:NO];
    [self.resignButton setEnabled:NO];
    
    NSPropertyListFormat plf = 1;
    NSError *error;
    self.gameDictionary = [NSPropertyListSerialization propertyListWithData:theMatch.matchData options:0 format:&plf error:&error];
    
    NSString *matchOutcome = [self checkWinner];
    
    if ([matchOutcome isEqualToString:@"Tie"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Over" message:@"Its a draw" delegate:nil cancelButtonTitle:@"Dimiss" otherButtonTitles: nil];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Over" message:theMatch.message delegate:nil cancelButtonTitle:@"Dimiss" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)resignDidSucceed:(GKTurnBasedMatch *)theMatch
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)resignDidFail:(GKTurnBasedMatch *)theMatch
{
    [self setButtonEnabled:YES];
    [self.resignButton setEnabled:YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Resign Failed" message:@"Your resign submission failed!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)endGameForDecline:(GKTurnBasedMatch *)theMatch
{
    [self setButtonEnabled:YES];
    [self.resignButton setEnabled:YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invite Declined" message:@"Your opponent has decline your match invitation!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)endGame:(GKTurnBasedMatch *)theMatch forResign:(BOOL)didResign
{
    [self setButtonEnabled:NO];
    [self.resignButton setEnabled:NO];
    
    if (didResign) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Opponent Resigned" message:@"Your opponent resigned from the match!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        
        NSString *matchOutcome = [self checkWinner];
        
        if ([matchOutcome isEqualToString:@"Tie"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Over" message:@"Its a draw" delegate:nil cancelButtonTitle:@"Dimiss" otherButtonTitles: nil];
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Over" message:theMatch.message delegate:nil cancelButtonTitle:@"Dimiss" otherButtonTitles: nil];
            [alert show];
        }
    }
}

							
@end
