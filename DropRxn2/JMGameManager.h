//
//  JMGameManager.h
//  DropRxn2
//
//  Created by James Mundie on 11/3/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "JMHelpers.h"
#import "GameViewController.h"

typedef void (^completion)(BOOL finished);

@class Circle;
@class GameViewController;
@class DropCounter;

@interface JMGameManager : NSObject

@property (nonatomic, assign) BOOL demoModeEnabled;
@property (nonatomic, strong) Circle *currentNextBall;
@property (nonatomic, strong) GameViewController *activeGameController;
@property (nonatomic, strong) DropCounter *dropCounter;
//@property (nonatomic, assign) BOOL shouldEndNow;
@property (nonatomic, assign) NSInteger chainCount;
@property (nonatomic, strong) NSNumber *currentScore;
@property (nonatomic, strong) NSNumber *highScore;
@property (nonatomic, strong) NSNumber *difficultyLevel;

+(instancetype)sharedInstance;
-(NSNumber *)getDifficultyLevel;
-(UIView *)getGameView;
-(void)setGameView:(UIView *)gameView;
-(NSArray *)getColumns;
-(void)resetGameWithCompletion:(completion)completion;
-(void)updateNextBall;
-(NSArray *)checkAdjacentsTo:(Circle *)ball;
-(NSNumber *)calculateNumberWithMultiplier:(NSNumber *)multiplier;

@end
