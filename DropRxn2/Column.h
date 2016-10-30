//
//  Column.h
//  DropRXN2
//
//  Created by James Mundie on 10/26/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "JMHelpers.h"

@class Circle;

@interface Column : UIView

-(void)addBallWithNumber:(NSNumber *)number;
-(void)cleanBalls;
-(NSArray *)getBalls;
-(NSArray *)checkColumnCount;
-(Circle *)ballAtRow:(NSNumber *)row;
-(void)addBallForNewRowWithNumber:(NSNumber *)number;
-(NSInteger)indexOfBall:(Circle *)ball;

@end
