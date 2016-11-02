//
//  GameViewController.h
//  DropRxn2
//
//  Created by James Mundie on 11/2/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "JMHelpers.h"

@interface GameViewController : UIViewController

{
    Circle *nextBall;
    DropCounter *dc;
}

@property (nonatomic, assign) BOOL isDemo;

-(void)resetGame;
-(void)addNextBall;
-(void)addColumns;
-(void)toggleUserInputPause;

@end
