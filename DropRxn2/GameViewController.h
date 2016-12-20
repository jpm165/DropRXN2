//
//  GameViewController.h
//  DropRxn2
//
//  Created by James Mundie on 11/2/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "JMHelpers.h"
#import "PowerUp.h"
@class DropCounter;
@protocol PowerUpInfoAndSelectProtocol;

@interface GameViewController : UIViewController <PowerUpInfoAndSelectProtocol>

{
    DropCounter *dc;
}

@property (nonatomic, strong) UIView *gameView;
@property (nonatomic, strong) UILabel *lvlLabel2;
@property (nonatomic, assign) BOOL isGameOver;
-(void)addNextBall;
-(void)removeDropCounter;
-(void)addDropCounter;
-(void)hideNextBall;
-(void)scoreUpdated;
-(void)handleGameOver;
-(void)gotBestChain:(NSNumber *)chainCount;
-(void)updateLevel:(NSNumber *)level;
-(void)changeMode:(GameMode)gameMode;
-(void)addedPowerUp;
-(void)startPowerMode;

@end
