//
//  GameViewController.h
//  DropRxn2
//
//  Created by James Mundie on 11/2/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "JMHelpers.h"
@class DropCounter;

@interface GameViewController : UIViewController

{
    DropCounter *dc;
}

@property (nonatomic, strong) UIView *gameView;
@property (nonatomic, strong) UILabel *lvlLabel2;
-(void)addNextBall;
-(void)removeDropCounter;
-(void)addDropCounter;
-(void)hideNextBall;
-(void)scoreUpdated;
-(void)handleGameOver;
-(void)gotBestChain:(NSNumber *)chainCount;
-(void)updateLevel:(NSNumber *)level;

@end
