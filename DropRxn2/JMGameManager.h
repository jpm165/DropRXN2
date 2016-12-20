//
//  JMGameManager.h
//  DropRxn2
//
//  Created by James Mundie on 11/3/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "JMHelpers.h"
#import "GameViewController.h"

@class PowerUp;

typedef void (^completion)(BOOL finished);

@class Circle;
@class DropCounter;
@class GameViewController;

@interface JMGameManager : NSObject

@property (nonatomic, assign) BOOL demoModeEnabled;
@property (nonatomic, strong) Circle *currentNextBall;
@property (nonatomic, strong) GameViewController *activeGameController;
@property (nonatomic, strong) DropCounter *dropCounter;
@property (nonatomic, assign) NSInteger chainCount;
@property (nonatomic, strong) NSNumber *currentScore;
@property (nonatomic, strong) NSNumber *bestChainCount;
@property (nonatomic, strong) NSMutableDictionary *highScores;
@property (nonatomic, strong) NSNumber *highscoreForCurrentDifficultyLevel;
@property (nonatomic, assign) GameDifficulty currentDifficulty;
@property (nonatomic, assign) GameMode currentGameMode;
@property (nonatomic, strong) NSMutableArray *selectedPowerups;



+(instancetype)sharedInstance;
-(UIView *)getGameView;
-(void)setGameView:(UIView *)gameView;
-(NSArray *)getColumns;
-(void)resetGameWithCompletion:(completion)completion;
-(void)updateNextBall;
-(NSArray *)checkAdjacentsTo:(Circle *)ball;
-(NSNumber *)calculateNumberWithMultiplier:(NSNumber *)multiplier;
-(NSNumber *)getHighScore;
-(void)incrementChainCount;
-(NSNumber *)getBestChainCount;
-(void)updateLevel:(NSNumber *)level;
-(void)addPowerUp:(PowerUp *)powerUp;

@end
