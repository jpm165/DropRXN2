//
//  GameViewController.h
//  DropRxn2
//
//  Created by James Mundie on 11/2/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "JMHelpers.h"

@interface GameViewController : UIViewController
@property (nonatomic, strong) UIView *gameView;
-(void)addNextBall;
-(void)removeDropCounter;
-(void)addDropCounter;
-(void)hideNextBall;
-(void)scoreUpdated;

@end
