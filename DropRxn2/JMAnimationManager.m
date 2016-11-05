//
//  JMAnimationManager.m
//  DropRXN2
//
//  Created by James Mundie on 10/26/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "JMAnimationManager.h"
#import "UIView+RZViewActions.h"
#import "ScoreSprite.h"


@interface JMAnimationManager ()

{
    //NSMutableArray *privateColumns;
    BOOL justAddedRow;
    NSInteger scoreAccumulator;
}

@end

@implementation JMAnimationManager

+(instancetype)sharedInstance {
    
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [self new];
    });
    
    return sharedInstance;
    
}

//TODO
/*
 -Still need to work on game loop and resetting. Still not totally resetting game when reset is called. MAybe try posting a reset nitification in reset and remove the animations in that handler. or maybe try decoupling the setup in new game view and demo game view. Just load them separately. I think this is stopping the animations now... now I just need to stop the score from updating...
 -when 9 is between 2 removed balls, shoudl it decrement 2x?
 -intercept leftward swipe to not go back
 -SWRevealViewController menu
 -count chains - display after matches handled
 -longest chain (persists)
 -best score (per mode)
 -score board and score
 -add up score and display
 -score persists
 -tweak animations
 -add difficulty by reducing the drop counter over time
 -change 8's and 9's to not display number, pick different way to convey
 -music
 -animate add row?
 -balancing: look into changing probability of certain values coming up as rows get higher
 -ads
 -in app purchase to remove adds
 -powerup mode
 -powerups
 -make a "GO" animation when user staets a new game?
 -set breakpoints at isAnimating=NO to find out why it's reverting to yes when the game is over. Also might set demoMode as soon as game ends in addrow as a workaround
 */

-(void)addRow {
    self.isAnimating = YES;
    for (Column *c in [[JMGameManager sharedInstance] getColumns]) {
        
        [c addBallForNewRowWithNumber:@([JMHelpers randomBasedOnRowCount:(int)[c getBalls].count])];
    }
    justAddedRow = YES;
    BOOL endGame = NO;
    
    for (Column *c in [[JMGameManager sharedInstance] getColumns]) {
        if ([c getBalls].count >= [JMHelpers numballs].integerValue+1) {
            endGame = YES;
        }
    }
    if (endGame) {
        self.isAnimating = YES;
        [JMGameManager sharedInstance].demoModeEnabled = YES;
        /*
        [self dropAllOffScreenWithCompletion:^(BOOL finished) {
            if (finished) {
                NSLog(@"Game Over!");
                [[NSNotificationCenter defaultCenter] postNotificationName:[JMHelpers gameOverNotification] object:nil];
                return;
            }
        }];
         */
        NSMutableArray *finalDrops = [NSMutableArray array];
        for (Column *col in [[JMGameManager sharedInstance] getColumns]) {
            NSMutableArray *columnDrops = [NSMutableArray array];
            NSArray *colBalls = [col getBalls];
            for (Circle *ball in colBalls) {
                CGRect newframe = CGRectMake(CGRectGetMinX(ball.frame), CGRectGetMaxY([UIScreen mainScreen].bounds)+CGRectGetHeight(ball.frame), CGRectGetWidth(ball.frame), CGRectGetHeight(ball.frame));
                RZViewAction *moveAction = [RZViewAction action:^{
                    ball.frame = newframe;
                } withDuration:0.45];
                [columnDrops addObject:moveAction];
            }
            [finalDrops addObject:[RZViewAction sequence:columnDrops]];
        }
        [UIView rz_runAction:[RZViewAction group:finalDrops] withCompletion:^(BOOL finished) {
            if (finished) {
                NSLog(@"Game Over!");
                [[NSNotificationCenter defaultCenter] postNotificationName:[JMHelpers gameOverNotification] object:nil];
                return;
            }
        }];
    } else {
        [UIView rz_runAction:[RZViewAction waitForDuration:0.1] withCompletion:^(BOOL finished) {
            if (finished) {
                [self doDrops];
            }
        }];
    }
    
}

-(void)endGameWithCompletion:(completion)endGameCompletion {
    
    [self dropAllOffScreenWithCompletion:^(BOOL finished) {
        if (finished) {
            NSLog(@"Animations done.");
            [JMAnimationManager sharedInstance].isAnimating = NO;
            endGameCompletion(YES);
        }
    }];
}


-(void)dropAllOffScreenWithCompletion:(completion)completion {
    self.isAnimating = YES;
    NSLog(@"in drop method!");
    NSMutableArray *finalDrops = [NSMutableArray array];
    for (Column *col in [[JMGameManager sharedInstance] getColumns]) {
        NSMutableArray *columnDrops = [NSMutableArray array];
        NSArray *colBalls = [col getBalls];
        for (Circle *ball in colBalls) {
            CGRect newframe = CGRectMake(CGRectGetMinX(ball.frame), CGRectGetMaxY([UIScreen mainScreen].bounds)+CGRectGetHeight(ball.frame), CGRectGetWidth(ball.frame), CGRectGetHeight(ball.frame));
            RZViewAction *moveAction = [RZViewAction action:^{
                ball.frame = newframe;
            } withOptions:UIViewAnimationOptionBeginFromCurrentState duration:0.45];
            [columnDrops addObject:moveAction];
        }
        [finalDrops addObject:[RZViewAction sequence:columnDrops]];
    }
    [UIView rz_runAction:[RZViewAction group:finalDrops] withCompletion:^(BOOL finished) {
        if (finished) {
            completion(YES);
        }
    }];
}


-(void)doDrops {
    //get all drop animations for each column
    self.isAnimating = YES;
    NSMutableArray *dropsArray = [NSMutableArray array];
    
    for (Column *col in [[JMGameManager sharedInstance] getColumns]) {
        
        //reverse the balls array
        NSArray *tmpArray = [[[col getBalls] reverseObjectEnumerator] allObjects];
        
        for (int i=0; i<tmpArray.count; i++) {
            Circle *c = tmpArray[i]; //for 0, this will be formerly the bottom one, expected index is 6.
            int comp = c.initialSlot.intValue; //i=0, expecting initial slot of 6.
            int test = [JMHelpers numballs].intValue-i-1; //this is the slot #in balls array
            if (test > comp) {
                int diff = (test-comp)*[JMHelpers circleRadius]; //diff is the number of slots the ball has to move
                float dampingDampener = i/100;
                float velocityReducer = i/10;
                RZViewAction *moveAction = [RZViewAction springAction:^{
                    c.frame = CGRectMake(CGRectGetMinX(c.frame),
                                         CGRectGetMinY(c.frame)+(diff),
                                         [JMHelpers circleRadius],
                                         [JMHelpers circleRadius]);
                } withDamping:0.85+dampingDampener initialVelocity:1.5-velocityReducer options:UIViewAnimationOptionCurveEaseIn duration:0.4];
                [dropsArray addObject:[RZViewAction sequence:@[moveAction, [RZViewAction waitForDuration:0.1]]]];
                
            }
            c.initialSlot = @(test);
        }
        
    }
    if (dropsArray.count ==0) [dropsArray addObject:[RZViewAction waitForDuration:0.2]];
    //Now i have a bunch of move actions in the drop array, or at least one.
    //do the drops
    [UIView rz_runAction:[RZViewAction group:dropsArray] withCompletion:^(BOOL finished) {
        if (finished) {
            self.isAnimating = NO;
            [self cleanBalls];//update the models
            [self setColumnBackgroundColor:[UIColor whiteColor]];
            [self handleMatches]; //There were drops, so handle the matches.
        }
    }];
   
}

-(void)cleanBalls {
    for (Column *c in [[JMGameManager sharedInstance] getColumns]) {
        [c cleanBalls];
    }
}

-(void)setColumnBackgroundColor:(UIColor *)color {
    for (Column *c in [[JMGameManager sharedInstance] getColumns]) {
        c.backgroundColor = color;
    }
}

-(void)handleMatches {
    if (self.shouldEndNow) return;
    //NSLog(@"Checking matches...");
    NSMutableSet *matches = [NSMutableSet set]; //keep track of matched objects to avoid duplicates
    self.isAnimating = YES;
    
    //check the columns
    NSMutableArray *removesArray = [NSMutableArray array];
    NSMutableArray *decrementsArray = [NSMutableArray array];
    //NSMutableArray *scoreAnimations = [NSMutableArray array];
    for (Column *col in [[JMGameManager sharedInstance] getColumns]) {
        NSArray *ballsToRemove = [col checkColumnCount];
        if (ballsToRemove.count > 0) {
            for (Circle *ball in ballsToRemove) {
                Circle *c = ball;
                [matches addObject:c];
                NSArray *array = [[JMGameManager sharedInstance] checkAdjacentsTo:c];
                if (array.count > 0) {
                    [decrementsArray addObjectsFromArray:array];
                }
                RZViewAction *removeAction1 = [RZViewAction action:^{
                    CGRect newFramePulseBig = CGRectMake(CGRectGetMinX(c.frame)-2.5, CGRectGetMinY(c.frame)-2.5, CGRectGetWidth(c.frame)+5, CGRectGetHeight(c.frame)+5);
                    
                    c.frame = newFramePulseBig;
                                    }
                                                     withDuration:0.1];
                RZViewAction *removeAction2 = [RZViewAction action:^{
                    CGRect newFrame = CGRectMake(CGRectGetMidX(c.frame), CGRectGetMidY(c.frame), 0, 0);
                    c.frame = newFrame;
                } withDuration:0.3];
                
                RZViewAction *removeSequence = [RZViewAction sequence:@[[col getFlashGridAtRow:@([col indexOfBall:ball inverted:YES]) on:YES],
                                                                        removeAction1,
                                                                        removeAction2,
                                                                        [RZViewAction group:@[[col getFlashGridAtRow:@([col indexOfBall:ball inverted:YES]) on:NO],
                                                                                              [col addScoreSpriteForBall:c]]
                                                                        ]]];
                [removesArray addObject:removeSequence];
            }
        }
    }
    //check the rows
    NSMutableArray *rows = [NSMutableArray array];
    
    //this loop gives us all the subrows as arrays
    for (int row=0; row<[JMHelpers numballs].intValue; row++) {
        NSMutableArray *currentRow = [NSMutableArray array];
        NSInteger count = [[JMGameManager sharedInstance] getColumns].count;
        for (int column=0; column<count; column++) {
            Column *col = [[JMGameManager sharedInstance] getColumns][column];
            Circle *ball = [col ballAtRow:@(row)];
            if (ball != nil) { //if there is a ball at that level, add it to the current row
                [currentRow addObject:ball];
            } else {
                //if there is not a ball, check if currentRow has been started.
                //if so, add it to rows, and reinitialize
                if (currentRow.count > 0) {
                    NSArray *rowCopy = [NSArray arrayWithArray:currentRow];
                    [rows addObject:rowCopy];
                    [currentRow removeAllObjects];
                }
            }
            if (column==count-1) {
                if (currentRow.count>0) {
                    NSArray *rowCopy = [NSArray arrayWithArray:currentRow];
                    [rows addObject:rowCopy];
                    [currentRow removeAllObjects];
                }
            }
        }
    }
    //now we need to check for matches in the rows...
    for (NSMutableArray *row in rows) {
        for (Circle *ball in row) {
            if (ball.number.intValue == row.count) {
                //match
                NSArray *array = [[JMGameManager sharedInstance] checkAdjacentsTo:ball];
                if (array.count > 0) {
                    [decrementsArray addObjectsFromArray:array];
                }
                if (![matches containsObject:ball]) {
                    ball.shouldRemove = YES;
                    [matches addObject:ball];
                    Circle *c = ball;
                    Column *col = [[JMGameManager sharedInstance] getColumns][ball.columnNumber.integerValue];
                    RZViewAction *removeAction1 = [RZViewAction action:^{
                        CGRect newFramePulseBig = CGRectMake(CGRectGetMinX(c.frame)-2.5, CGRectGetMinY(c.frame)-2.5, CGRectGetWidth(c.frame)+5, CGRectGetHeight(c.frame)+5);
                        
                        c.frame = newFramePulseBig;
                    }
                                                          withDuration:0.1];
                    RZViewAction *removeAction2 = [RZViewAction action:^{
                        CGRect newFrame = CGRectMake(CGRectGetMidX(c.frame), CGRectGetMidY(c.frame), 0, 0);
                        c.frame = newFrame;
                    } withDuration:0.3];
                    RZViewAction *removeSequence = [RZViewAction sequence:@[[col getFlashGridAtRow:@([col indexOfBall:ball inverted:YES]) on:YES],
                                                                            removeAction1,
                                                                            removeAction2,
                                                                            [RZViewAction group:@[[col getFlashGridAtRow:@([col indexOfBall:ball inverted:YES]) on:NO],
                                                                                                  [col addScoreSpriteForBall:c]]
                                                                             ]]];
                    [removesArray addObject:removeSequence];
                    
                }
            }
        }
    }
    NSMutableArray *decAnimArray = [NSMutableArray array];
    NSMutableArray *ballsToChange = [NSMutableArray array];
    if (decrementsArray.count > 0) {
        for (Circle *ball in decrementsArray) {
            NSNumber *changeTo;
            if (ball.number.integerValue == [JMHelpers numballs].integerValue+1) {
                changeTo = @([JMHelpers randomNonGrey]);
            } else {
                changeTo = @(ball.number.integerValue-1);
            }
            [decAnimArray addObject:[ball changeNumber:@0]];
            [ballsToChange addObject:@{@"ball":ball, @"numberTo":changeTo}];
        }
    }
    
    //now if we have any matches, remove, clean, and recurse
    if (removesArray.count>0) {
        if (self.shouldEndNow) {
            return;
        }
        RZViewAction *theAction = [RZViewAction sequence:@[[RZViewAction group:removesArray], [RZViewAction group:decAnimArray]]];
        [UIView rz_runAction:theAction withCompletion:^(BOOL finished) {
            if (finished) {
                if (self.shouldEndNow) {
                    return;
                }
                for (NSDictionary *dict in ballsToChange) {
                    Circle *ball = dict[@"ball"];
                    NSNumber *num = dict[@"numberTo"];
                    [ball setNumber:num];
                }
                for (Circle __strong *ball in matches) {
                    [ball removeFromSuperview];
                    ball = nil;
                }
                for (Column *col in [[JMGameManager sharedInstance] getColumns]) {
                    [col removeScoreSprites];
                }
                if (![JMGameManager sharedInstance].demoModeEnabled) {
                    for (Circle *ball in matches) {
                        NSInteger bs = ball.number.integerValue;
                        bs++;
                        scoreAccumulator += [[JMGameManager sharedInstance] calculateNumberWithMultiplier:@([[JMGameManager sharedInstance] chainCount])].integerValue;
                        //[[JMGameManager sharedInstance] setCurrentScore:[[JMGameManager sharedInstance] calculateNumberWithMultiplier:@([[JMGameManager sharedInstance] chainCount])]];
                    }
                }
                self.isAnimating = NO;
                [self cleanBalls];
                [JMGameManager sharedInstance].chainCount++;
                
                [self doDrops];
            }
        }];
        
    } else {
        if (!justAddedRow) {
            [[JMGameManager sharedInstance].dropCounter decrementCurrentDrop];
        } else {
            justAddedRow = NO;
        }
        NSInteger numdrops = [JMHelpers numDrops];
        if ([JMGameManager sharedInstance].demoModeEnabled) numdrops = 0;
        if ([JMGameManager sharedInstance].dropCounter.currentDrop == 0) {
            if (!self.shouldEndNow) {
                [[JMGameManager sharedInstance].dropCounter decrementCurrentDrop];
                [self addRow];
            }
        }
        self.isAnimating = NO;
        //otherwise return control to the user
        [[JMGameManager sharedInstance] setCurrentScore:@(scoreAccumulator)];
        scoreAccumulator = 0;
    }
    
}

@end
