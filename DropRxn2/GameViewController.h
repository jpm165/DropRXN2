//
//  GameViewController.h
//  DropRxn2
//
//  Created by James Mundie on 11/2/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "JMHelpers.h"

@class DropCounter;
@class PowerUp;

@interface GameViewController : UIViewController

{
    DropCounter *dc;
}

@property (nonatomic, strong) UIView *gameView;
@property (nonatomic, strong) UILabel *lvlLabel2;
@property (nonatomic, assign) BOOL isGameOver;
@property (nonatomic, assign) BOOL isPresentingPopover;
@property (nonatomic, strong) PowerUp *currentlySelectedPowerUp;

-(void)addNextBall;
-(void)removeDropCounter;
-(void)addDropCounter;
-(void)hideNextBall;
-(void)scoreUpdated;
-(void)handleGameOver;
-(void)gotBestChain:(NSNumber *)chainCount;
-(void)updateLevel:(NSNumber *)level;
-(void)changeMode:(GameMode)gameMode;
-(void)addedPowerUp:(BOOL)doneAddingPowerUps;
-(void)startPowerMode;
-(void)addPassthroughPowerUpView:(id)sender;


@end
