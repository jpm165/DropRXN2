//
//  JMAnimationManager.m
//  DropRXN2
//
//  Created by James Mundie on 10/26/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "JMAnimationManager.h"
#import "UIView+RZViewActions.h"


@interface JMAnimationManager ()

{
    //NSMutableArray *privateColumns;
    BOOL justAddedRow;
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
 -intercept leftward swipe to not go back
 -SWRevealViewController menu
 -Game over screen
 -score board and score
 -score animations.
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
 -Test: 8+ number setting works for all matches
 -If not, make a "GO" animation when user staets a new game
 */

-(void)addRow {
    
    for (Column *c in [[JMGameManager sharedInstance] getColumns]) {
        
        [c addBallForNewRowWithNumber:@([JMHelpers randomBasedOnRowCount:(int)[c getBalls].count])];
    }
    justAddedRow = YES;
    BOOL endGame = NO;
    
    for (Column *c in [[JMGameManager sharedInstance] getColumns]) {
        if ([c getBalls].count >= [JMHelpers numballs].integerValue-2) {
            endGame = YES;
        }
    }
    if (endGame) {
        [self dropAllOffScreenWithCompletion:^(BOOL finished) {
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
            } withDuration:0.5];
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
    //NSLog(@"Checking matches...");
    NSMutableSet *matches = [NSMutableSet set]; //keep track of matched objects to avoid duplicates
    self.isAnimating = YES;
    
    //check the columns
    NSMutableArray *removesArray = [NSMutableArray array];
    NSMutableArray *flashOnArray = [NSMutableArray array];
    NSMutableArray *flashOffArray = [NSMutableArray array];
    NSMutableArray *decrementsArray = [NSMutableArray array];
    for (Column *col in [[JMGameManager sharedInstance] getColumns]) {
        NSArray *ballsToRemove = [col checkColumnCount];
        if (ballsToRemove.count > 0) {
            for (Circle *ball in ballsToRemove) {
                Circle *c = ball;
                [matches addObject:c];
                [flashOnArray addObject:[col getFlashGridAtRow:@([col indexOfBall:ball inverted:YES]) on:YES]];
                [flashOffArray addObject:[col getFlashGridAtRow:@([col indexOfBall:ball inverted:YES]) on:NO]];
                //[[JMGameManager sharedInstance] checkAdjacentsTo:c];
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
                RZViewAction *removeSequence = [RZViewAction sequence:@[removeAction1, removeAction2]];
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
                //[[JMGameManager sharedInstance] checkAdjacentsTo:ball];
                NSArray *array = [[JMGameManager sharedInstance] checkAdjacentsTo:ball];
                if (array.count > 0) {
                    [decrementsArray addObjectsFromArray:array];
                }
                if (![matches containsObject:ball]) {
                    ball.shouldRemove = YES;
                    [matches addObject:ball];
                    Circle *c = ball;
                    Column *col = [[JMGameManager sharedInstance] getColumns][ball.columnNumber.integerValue];
                    [flashOnArray addObject:[col getFlashGridAtRow:@([col indexOfBall:ball inverted:YES]) on:YES]];
                    [flashOffArray addObject:[col getFlashGridAtRow:@([col indexOfBall:ball inverted:YES]) on:NO]];
                    RZViewAction *removeAction1 = [RZViewAction action:^{
                        CGRect newFramePulseBig = CGRectMake(CGRectGetMinX(c.frame)-2.5, CGRectGetMinY(c.frame)-2.5, CGRectGetWidth(c.frame)+5, CGRectGetHeight(c.frame)+5);
                        
                        c.frame = newFramePulseBig;
                    }
                                                          withDuration:0.1];
                    RZViewAction *removeAction2 = [RZViewAction action:^{
                        CGRect newFrame = CGRectMake(CGRectGetMidX(c.frame), CGRectGetMidY(c.frame), 0, 0);
                        c.frame = newFrame;
                    } withDuration:0.3];
                    RZViewAction *removeSequence = [RZViewAction sequence:@[removeAction1, removeAction2]];
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
        [UIView rz_runAction:[RZViewAction group:flashOnArray] withCompletion:^(BOOL finished) {
            if (finished) {
                [UIView rz_runAction:[RZViewAction group:removesArray] withCompletion:^(BOOL finished) {
                    if (finished) {
                        [UIView rz_runAction:[RZViewAction group:flashOffArray] withCompletion:^(BOOL finished) {
                            if (finished) {
                                [UIView rz_runAction:[RZViewAction group:decAnimArray] withCompletion:^(BOOL finished) {
                                    if (finished) {
                                        for (NSDictionary *dict in ballsToChange) {
                                            Circle *ball = dict[@"ball"];
                                            NSNumber *num = dict[@"numberTo"];
                                            [ball setNumber:num];
                                        }
                                        for (Circle __strong *ball in matches) {
                                            [ball removeFromSuperview];
                                            ball = nil;
                                        }
                                        self.isAnimating = NO;
                                        [self cleanBalls];
                                        [self doDrops];
                                    }
                                }];
                                
                            }
                        }];
                        
                    }
                }];
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
            if (![JMGameManager sharedInstance].shouldEndNow) {
                [[JMGameManager sharedInstance].dropCounter decrementCurrentDrop];
                [self addRow];
            }
        }
        self.isAnimating = NO; //otherwise return control to the user
    }
    
}

@end
