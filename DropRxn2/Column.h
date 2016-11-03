//
//  Column.h
//  DropRXN2
//
//  Created by James Mundie on 10/26/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "JMHelpers.h"

@class Circle;
@class RZViewAction;

@interface Column : UIView

@property (nonatomic, strong) NSNumber *columnNumber;

-(RZViewAction *)addBallWithNumber:(NSNumber *)number;
-(void)cleanBalls;
-(NSArray *)getBalls;
-(NSArray *)checkColumnCount;
-(Circle *)ballAtRow:(NSNumber *)row;
-(void)addBallForNewRowWithNumber:(NSNumber *)number;
-(NSInteger)indexOfBall:(Circle *)ball inverted:(BOOL)inverted;
-(RZViewAction *)getFlashGridAtRow:(NSNumber *)rowNum on:(BOOL)on;
-(void)reset;
-(void)autoAddBallWithNumber:(NSNumber *)number;

@end
