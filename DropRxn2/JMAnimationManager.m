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
    NSMutableArray *privateColumns;
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

-(void)addColumn:(Column *)column {
    if (!self.columns) self.columns = [NSArray array];
    if (!privateColumns) privateColumns = [NSMutableArray array];
    
    if (privateColumns.count < [JMHelpers numColumns].integerValue) {
        [privateColumns addObject:column];
        self.columns = privateColumns;
    }
}

-(void)removeAllColumns {
    [privateColumns removeAllObjects];
    self.columns = privateColumns;
}

//TODO
/*
 -Still a problem with add row. If a row is full when a row is added, the game is over, but there is a case where the game could be saved: if the row is full, but a match occurs as a result of the row add that results in the full row losing a ball after the row is added. need to move the check game over condition to the end of handle checks. Can maybe test this by defining what would trigger the condition, determining the drop order for that state, and dropping that state instead of dropping random new balls.
 -counter not quite working right. decrements one too much after first time through
 -game over not working
 -Game over screen
 -score board and score
 -score animations.
 -score persists
 -tweak animations
 -(auto play happens by changing the counter to 1.)
 -add difficulty by reducing the drop counter
 -detect removals and decrement adjacent 8's and 9's (make value random 1-7 after decremented from 8)
 -music
 -animate add row?
 -highlight selected column
 
 */

-(void)addRow {
    
    for (Column *c in privateColumns) {
        [c addBallForNewRowWithNumber:@([JMHelpers random])];
    }
    [UIView rz_runAction:[RZViewAction waitForDuration:0.1] withCompletion:^(BOOL finished) {
        if (finished) {
            [self doDrops];
        }
    }];
    
}

-(void)doDrops {
    //NSLog(@"Dropping...");
    //get all drop animations for each column
    [[NSNotificationCenter defaultCenter] postNotificationName:[JMHelpers toggleUserInputPauseNotification] object:nil];
    NSMutableArray *dropsArray = [NSMutableArray array];
    
    for (Column *col in privateColumns) {
        
        //reverse the balls array
        NSArray *tmpArray = [[[col getBalls] reverseObjectEnumerator] allObjects];
        
        for (int i=0; i<tmpArray.count; i++) {
            Circle *c = tmpArray[i]; //for 0, this will be formerly the bottom one, expected index is 6.
            int comp = c.initialSlot.intValue; //i=0, expecting initial slot of 6.
            int test = [JMHelpers numballs].intValue-i-1; //this is the slot #in balls array
            if (test > comp) {
                int diff = (test-comp)*[JMHelpers circleRadius]; //diff is the number of slots the ball has to move
                RZViewAction *moveAction = [RZViewAction action:^{
                    c.frame = CGRectMake(CGRectGetMinX(c.frame),
                                         CGRectGetMinY(c.frame)+(diff),
                                         [JMHelpers circleRadius],
                                         [JMHelpers circleRadius]);}
                                                   withDuration:0.3];
                [dropsArray addObject:moveAction];
                [dropsArray addObject:[RZViewAction waitForDuration:0.1]];
            }
            c.initialSlot = @(test);
        }
        
    }
    if (dropsArray.count ==0) [dropsArray addObject:[RZViewAction waitForDuration:0.2]];
    //Now i have a bunch of move actions in the drop array, or at least one.
    //do the drops
    //if (dropsArray.count > 0) {
    //    handleMatchesAnyway = NO;
        [UIView rz_runAction:[RZViewAction group:dropsArray] withCompletion:^(BOOL finished) {
                if (finished) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:[JMHelpers toggleUserInputPauseNotification] object:nil];
                    [self cleanBalls]; //update the models
                    [self handleMatches]; //There were drops, so handle the matches.
                }
            }];
   // }
    
   // if (handleMatchesAnyway) {
   //     [[NSNotificationCenter defaultCenter] postNotificationName:[JMHelpers toggleUserInputPauseNotification] object:nil];
   //     [self handleMatches];
   // }
}

-(void)cleanBalls {
    for (Column *c in privateColumns) {
        [c cleanBalls];
    }
}

-(void)handleMatches {
    //NSLog(@"Checking matches...");
    NSMutableSet *matches = [NSMutableSet set]; //keep track of matched objects to avoid duplicates
    [[NSNotificationCenter defaultCenter] postNotificationName:[JMHelpers toggleUserInputPauseNotification] object:nil];
    
    //check the columns
    NSMutableArray *removesArray = [NSMutableArray array];
    for (Column *col in privateColumns) {
        NSArray *ballsToRemove = [col checkColumnCount];
        if (ballsToRemove.count > 0) {
            for (Circle *c in ballsToRemove) {
                [matches addObject:c];
                RZViewAction *removeAction = [RZViewAction action:^{
                    CGRect newFrame = CGRectMake(CGRectGetMidX(c.frame), CGRectGetMidY(c.frame), 0, 0);
                    c.frame = newFrame;
                }
                                                     withDuration:0.25];
                RZViewAction *wait = [RZViewAction waitForDuration:1];
                [removesArray addObject:removeAction];
                [removesArray addObject:wait];
            }
        }
    }
    //check the rows
    NSMutableArray *rows = [NSMutableArray array];
    
    //this loop gives us all the subrows as arrays
    for (int row=0; row<[JMHelpers numballs].intValue; row++) {
        NSMutableArray *currentRow = [NSMutableArray array];
        for (int column=0; column<privateColumns.count; column++) {
            Column *col = privateColumns[column];
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
            if (column==privateColumns.count-1) {
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
                if (![matches containsObject:ball]) {
                    ball.shouldRemove = YES;
                    [matches addObject:ball];
                    RZViewAction *removeAction = [RZViewAction action:^{ //TODO move this animation construction to Circle object
                        CGRect newFrame = CGRectMake(CGRectGetMidX(ball.frame), CGRectGetMidY(ball.frame), 0, 0);
                        ball.frame = newFrame;
                    }
                                                         withDuration:0.25];
                    RZViewAction *wait = [RZViewAction waitForDuration:1];
                    [removesArray addObject:removeAction];
                    [removesArray addObject:wait];
                }
            }
        }
    }
    
    //now if we have any matches, remove, clean, and recurse
    if (removesArray.count>0) {
        //NSLog(@"Removing matches...");
        [UIView rz_runAction:[RZViewAction group:removesArray] withCompletion:^(BOOL finished) {
            if (finished) {
                [[NSNotificationCenter defaultCenter] postNotificationName:[JMHelpers toggleUserInputPauseNotification] object:nil];
                [self cleanBalls];
                [self doDrops];
            }
        }];
    } else {
        BOOL shouldCheckEndGameState = YES;
        if ([self.dropCounter decrementCurrentDrop] == [JMHelpers numDrops]) {
            shouldCheckEndGameState = NO;
            [self addRow];
        }
        if (shouldCheckEndGameState) {
            for (Column *col in privateColumns) {
                if ([col getBalls].count == [JMHelpers numballs].integerValue+1) {
                    NSLog(@"Game Over!");
                    [[NSNotificationCenter defaultCenter] postNotificationName:[JMHelpers gameOverNotification] object:nil];
                    return;
                }
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:[JMHelpers toggleUserInputPauseNotification] object:nil];
    }
    //otherwise return control to the user
}

@end
