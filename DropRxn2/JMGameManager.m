//
//  JMGameManager.m
//  DropRxn2
//
//  Created by James Mundie on 11/3/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "JMGameManager.h"
#import "JMPersistenceManager.h"

@interface JMGameManager ()

@property (nonatomic, strong) UIView *myGameView;
@property (nonatomic, strong) NSMutableArray *myColumns;
@property (nonatomic, strong) Circle *myNextBall;

@end

@implementation JMGameManager

-(void)setDifficultyLevel:(NSNumber *)difficultyLevel {
    if (difficultyLevel.intValue < 0 || difficultyLevel.intValue > self.difficulties.count) return;
    _difficultyLevel = difficultyLevel;
    _currentDifficulty = self.difficulties[difficultyLevel.integerValue];
    _highscoreForCurrentDifficultyLevel = [[JMPersistenceManager sharedInstance] getHighScoreForDifficultyLevel:_currentDifficulty];
    _bestChainCount = [[JMPersistenceManager sharedInstance] getMostChainsForDifficultyLevel:_currentDifficulty];
}

-(NSNumber *)getDifficultyLevel {
    if (!_difficultyLevel) return [JMHelpers defaultDifficulty];
    return _difficultyLevel;
}

+(instancetype)sharedInstance {
    
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [self new];
    });
    
    return sharedInstance;
    
}

-(id)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:[JMHelpers gameOverNotification] object:nil];
        self.difficulties = @[@"easy", @"less easy", @"harder", @"more harder", @"insane"];
        self.currentDifficulty = @"easy";
        [self loadHighScores];
    }
    return self;
}

-(void)loadHighScores {
    NSDictionary *dict = [[JMPersistenceManager sharedInstance] getState];
    if (dict) {
        self.highScores = [dict mutableCopy];
    } else {
        self.highScores = [@{@"easy": @{@"score": @0, @"chains": @0},
                             @"less easy": @{@"score": @0, @"chains": @0},
                             @"harder": @{@"score": @0, @"chains": @0},
                             @"more harder": @{@"score": @0, @"chains": @0},
                             @"insane": @{@"score": @0, @"chains": @0}} mutableCopy];
    }
}

-(void)handleNotification:(NSNotification *)notification {
    [self.activeGameController handleGameOver];
}

-(NSNumber *)getBestChainCount {
    if (!_bestChainCount) {
        _bestChainCount = [[JMPersistenceManager sharedInstance] getMostChainsForDifficultyLevel:_currentDifficulty];
    }
    return _bestChainCount;
}

-(NSNumber *)getHighScore {
    
    if (!_highscoreForCurrentDifficultyLevel) {
        _highscoreForCurrentDifficultyLevel = [[JMPersistenceManager sharedInstance] getHighScoreForDifficultyLevel:_currentDifficulty];
    }
    return _highscoreForCurrentDifficultyLevel;
}

-(void)incrementChainCount {
    self.chainCount++;
    if (_chainCount >= _bestChainCount.integerValue) {
        _bestChainCount = @(_chainCount);
        NSMutableDictionary *dict = [self.highScores mutableCopy];
        NSDictionary *statsDict = dict[_currentDifficulty];
        NSDictionary *targetDict = @{@"score": statsDict[@"score"], @"chains":_bestChainCount};
        dict[_currentDifficulty] = targetDict;
        self.highScores = dict;
        [[JMPersistenceManager sharedInstance] saveState];
    }
}

-(void)setCurrentScore:(NSNumber *)currentScore {
    if (currentScore.intValue==0) return;
    long score = _currentScore.intValue;
    score += currentScore.longValue;
    _currentScore = @(score);
    long highscore = [self getHighScore].longValue;
    if (highscore <= score) {
        self.highscoreForCurrentDifficultyLevel = _currentScore;
        NSMutableDictionary *dict = [self.highScores mutableCopy];
        NSDictionary *statsDict = dict[_currentDifficulty];
        NSDictionary *targetDict = @{@"score": _highscoreForCurrentDifficultyLevel, @"chains": statsDict[@"chains"]};
        dict[_currentDifficulty] = targetDict;
        self.highScores = dict;
        [[JMPersistenceManager sharedInstance] saveState];
    }
    NSLog(@"in set score");
    if (![JMAnimationManager sharedInstance].shouldEndNow) [self.activeGameController scoreUpdated];
}

-(NSNumber *)calculateNumberWithMultiplier:(NSNumber *)multiplier {
    /*
     formula: for n chains, score = (7 + (n*7))* n) * (tier multiplier)
     = (7n +7)n * tm
     = 7n^2 +7n * tm
     -0: 7 x1
     -1: 14 x1
     -2: 42 x1
     -3: 84 x1
     -4: 140 * 2 = 280
     -5: 420 x2
     -6: 882 x3
     -7: 1176 x3
     -8: 1512 x3
     -9: 2520 x4
     -10: x4
     -11: x4
     -12: x4
     -13: x5 = 6370 (max)
     */
    long num = multiplier.longValue;
    if (num==13) return @(6370);
    if (num==0) return @(7);
    int tierMultiplier = 1;
    if (num >= 4) tierMultiplier++;
    if (num >= 6) tierMultiplier++;
    if (num >= 9) tierMultiplier++;
    NSNumber *score = @(((7*num*num)+(7*num))*tierMultiplier);
    //[self setCurrentScore:score];
    NSLog(@"after score updated");
    //dispatch_async(dispatch_get_main_queue(), ^{
    //[[NSNotificationCenter defaultCenter] postNotificationName:[JMHelpers currentScoreUpdateNotification] object:nil];
    //});
    return score;
}

-(UIView *)getGameView {
    return self.myGameView;
}

-(void)setGameView:(UIView *)gameView {
    self.myGameView = gameView;
}

-(NSArray *)getColumns {
    if (!self.myColumns) self.myColumns = [NSMutableArray array];
    return self.myColumns;
}

-(void)resetGameWithCompletion:(completion)completion {
    [[JMAnimationManager sharedInstance] endGameWithCompletion:^(BOOL finished) {
        if (finished) {
            [self addColumns];
            _currentScore = @0;
            
            completion(YES);
        }
    }];
    
}

-(void)addColumns {
    for (Column *col in self.myColumns) {
        [col reset];
    }
    [_myColumns removeAllObjects];
    
    //if (!_myColumns) {
        _myColumns = [NSMutableArray array];
        for (int i=0; i<[JMHelpers numColumns].intValue; i++) {
            Column *column = [[Column alloc] initWithFrame:[JMHelpers calculateColumnFrameAtPoint:CGPointZero offset:i]];
            column.columnNumber = @(i);
            [self.myGameView addSubview:column];
            [self.myColumns addObject:column];
        }
    //} else {
    
    //}
}

-(Circle *)currentNextBall {
    if (self.myNextBall) return self.myNextBall;
    return [self nextBall];
}

-(void)updateNextBall {
    self.myNextBall = [self nextBall];
    [self.activeGameController addNextBall];
    int counter = 0;
    for (UIView *view in self.myGameView.subviews) {
        if ([view isKindOfClass:[Column class]]) {
            for (UIView *subview in view.subviews) {
                if ([subview isKindOfClass:[Circle class]]) counter++;
            }
        }
    }
    NSLog(@"Number of balls in GameView: %d", counter);
}

-(Circle *)nextBall {
    self.myNextBall = [[Circle alloc] initWithFrame:CGRectZero borderWidth:[JMHelpers borderWidth]];
    self.myNextBall.number = @([JMHelpers random]);
    return self.myNextBall;
}


-(Circle *)checkBallAbove:(Circle *)ball {
     Column *col = self.myColumns[ball.columnNumber.integerValue];
    NSInteger indexOfMatch = [col indexOfBall:ball inverted:YES];
    Circle *ballAbove = [col ballAtRow:@(indexOfMatch+1)];
    if (ballAbove) {
        if (ballAbove.number.integerValue > [JMHelpers numballs].integerValue) {
            //            if (ballAbove.number.integerValue == [JMHelpers numballs].integerValue+1) {
            //                [ballAbove changeNumber:@([JMHelpers randomNonGrey])];
            //            } else {
            //                [ballAbove changeNumber:@(ballAbove.number.integerValue-1)];
            //            }
            return ballAbove;
        }
    }
    
    return nil;
   
}


-(Circle *)checkBallBelow:(Circle *)ball {
    Column *col = self.myColumns[ball.columnNumber.integerValue];
    NSInteger indexOfMatch = [col indexOfBall:ball inverted:YES];
    if (indexOfMatch > 0) {
        Circle *ballBelow = [col ballAtRow:@(indexOfMatch-1)];
            if (ballBelow) {
                if (ballBelow.number.integerValue > [JMHelpers numballs].integerValue) {
//                    if (ballBelow.number.integerValue == [JMHelpers numballs].integerValue+1) {
//                        [ballBelow changeNumber:@([JMHelpers randomNonGrey])];
//                    } else {
//                        [ballBelow changeNumber:@(ballBelow.number.integerValue-1)];
//                    }
                    return ballBelow;
                }
            }
        
    }
    return nil;
 }

-(Circle *)checkBallLeftOf:(Circle *)ball {
    Column *ballCol = self.myColumns[ball.columnNumber.integerValue];
    Column *leftCol;
    Circle *leftBall;
    if (ball.columnNumber.integerValue > 0) leftCol = self.myColumns[ball.columnNumber.integerValue-1];
    NSInteger indexOfMatch = [ballCol indexOfBall:ball inverted:YES];
    if (leftCol && indexOfMatch <= leftCol.getBalls.count-1) leftBall = [leftCol ballAtRow:@(indexOfMatch)];
    
    if (leftBall && leftBall.number.integerValue > [JMHelpers numballs].integerValue) {
        return leftBall;
    }
    return nil;
}

-(Circle *)checkBallRightOf:(Circle *)ball {
    Column *ballCol = self.myColumns[ball.columnNumber.integerValue];
    Column *rightCol;
    Circle *rightBall;
    if (ball.columnNumber.integerValue <= self.myColumns.count-2) rightCol = self.myColumns[ball.columnNumber.integerValue+1];
    NSInteger indexOfMatch = [ballCol indexOfBall:ball inverted:YES];
    if (rightCol && indexOfMatch <= rightCol.getBalls.count-1) rightBall = [rightCol ballAtRow:@(indexOfMatch)];
    if (rightBall && rightBall.number.integerValue > [JMHelpers numballs].integerValue) {
        return rightBall;
    }
    return nil;
}


-(void)checkBallLeftAndRightOf:(Circle *)ball {
    Column *ballCol = self.myColumns[ball.columnNumber.integerValue];
    Column *rightCol;
    Column *leftCol;
    Circle *leftBall;
    Circle *rightBall;
    if (ball.columnNumber.integerValue > 0) leftCol = self.myColumns[ball.columnNumber.integerValue-1];
    if (ball.columnNumber.integerValue <= self.myColumns.count-2) rightCol = self.myColumns[ball.columnNumber.integerValue+1];
 
    NSInteger indexOfMatch = [ballCol indexOfBall:ball inverted:YES];
 
    if (leftCol && indexOfMatch <= leftCol.getBalls.count-1) leftBall = [leftCol ballAtRow:@(indexOfMatch)];
    if (rightCol && indexOfMatch <= rightCol.getBalls.count-1) rightBall = [rightCol ballAtRow:@(indexOfMatch)];
 
    if (leftBall && leftBall.number.integerValue > [JMHelpers numballs].integerValue) {
        if (leftBall.number.integerValue == [JMHelpers numballs].integerValue+1) {
            [leftBall changeNumber:@([JMHelpers randomNonGrey])];
        } else {
            [leftBall changeNumber:@(leftBall.number.integerValue-1)];
        }
 
    }
    if (rightBall && rightBall.number.integerValue > [JMHelpers numballs].integerValue) {
        if (rightBall.number.integerValue == [JMHelpers numballs].integerValue+1) {
            [rightBall changeNumber:@([JMHelpers randomNonGrey])];
        } else {
            [rightBall changeNumber:@(rightBall.number.integerValue-1)];
        }
    }
}


-(NSArray *)checkAdjacentsTo:(Circle *)ball {
    NSMutableArray *retval = [NSMutableArray array];
    Circle *ballAbove = [self checkBallAbove:ball];
    if (ballAbove) [retval addObject:ballAbove];
    Circle *ballBelow = [self checkBallBelow:ball];
    if (ballBelow) [retval addObject:ballBelow];
    Circle *ballLeft = [self checkBallLeftOf:ball];
    if (ballLeft) [retval addObject:ballLeft];
    Circle *ballRight = [self checkBallRightOf:ball];
    if (ballRight) [retval addObject:ballRight];
    return retval;
}


//-(void)resetGame {
//    if ([[JMAnimationManager sharedInstance] columns].count > 0) {
//        [[JMAnimationManager sharedInstance] removeAllColumns];
//    }
//    [self addColumns];
//    [self removeAllBalls];
//    [self addNextBall];
//
//    [self removeEffectViews];
//
//    if (dc) {
//        [dc removeFromSuperview];
//        dc = nil;
//    }
//    dc = [[DropCounter alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.bounds)-([JMHelpers columnsWidth]/2), CGRectGetMidY(self.view.bounds)+([JMHelpers columnHeight]/2)+3, [JMHelpers columnsWidth], 10)];
//    [self.view addSubview:dc];
//    [JMAnimationManager sharedInstance].dropCounter = dc;
//}

@end
