//
//  Column.m
//  DropRXN2
//
//  Created by James Mundie on 10/26/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "Column.h"
#import "GridBox.h"

@interface Column ()

{
    NSMutableArray *balls;
    UIBezierPath *borderPath;
    NSMutableArray *gridBoxes;
}

@end

@implementation Column

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        balls = [NSMutableArray arrayWithCapacity:[JMHelpers numballs].integerValue];
        self.backgroundColor = [UIColor clearColor];
        [self addGrid];
    }
    return self;
}

-(void)addGrid {
    if (!gridBoxes) gridBoxes = [NSMutableArray array];
    for (int i=0; i<[JMHelpers numballs].integerValue; i++) {
        GridBox *gb = [[GridBox alloc] initWithFrame:CGRectMake(0, [JMHelpers circleRadius]*i, [JMHelpers circleRadius], [JMHelpers circleRadius])];
        [self addSubview:gb];
        [gridBoxes insertObject:gb atIndex:0];
    }
}

-(RZViewAction *)getFlashGridAtRow:(NSNumber *)rowNum on:(BOOL)on {
    GridBox *gb = gridBoxes[rowNum.integerValue];
    if (on) return [gb flashOnBG];
    return [gb flashOffBG];
}

-(void)addBallForNewRowWithNumber:(NSNumber *)number {
    CGPoint startPoint = CGPointMake(0, [JMHelpers circleRadius]*([JMHelpers numballs].floatValue-1));
    Circle *circle = [[Circle alloc] initWithFrame:CGRectMake(startPoint.x, startPoint.y, [JMHelpers circleRadius], [JMHelpers circleRadius]) borderWidth:[JMHelpers borderWidth]];
    [circle setNumber:number];
    circle.columnNumber = self.columnNumber;
    circle.initialSlot = @([JMHelpers numballs].intValue-1);
    [balls addObject:circle];
    
    for (int ball=0; ball<balls.count-1; ball++) {
        Circle *c = balls[ball];
        CGRect newFrame = CGRectMake(CGRectGetMinX(c.frame), CGRectGetMinY(c.frame)-[JMHelpers circleRadius], [JMHelpers circleRadius], [JMHelpers circleRadius]);
        c.frame = newFrame;
    }
    [self addSubview:circle];
}


-(void)addBallWithNumber:(NSNumber *)number {
    if (balls.count == [JMHelpers numballs].integerValue) return;
    CGPoint startPoint = CGPointMake(0, -[JMHelpers circleRadius]);
    Circle *circle = [[Circle alloc] initWithFrame:CGRectMake(startPoint.x, startPoint.y, [JMHelpers circleRadius], [JMHelpers circleRadius]) borderWidth:[JMHelpers borderWidth]];
    [circle setNumber:number];
    circle.columnNumber = self.columnNumber;
    circle.initialSlot = @(-1);
    [balls insertObject:circle atIndex:0];
    [self addSubview:circle];
    [[JMAnimationManager sharedInstance] doDrops];
}

-(void)cleanBalls {
    NSMutableArray *array = [balls mutableCopy];
    for (Circle *c in array) {
        if (c.shouldRemove) {
            //remove if blank
            //that should shift all elements down by one
            [balls removeObject:c];
        }
    }
}

-(NSArray *)getBalls {
    return balls;
}

-(NSArray *)checkColumnCount {
    //check for balls matching column count, mark for removal
    NSMutableArray *b2R = [NSMutableArray array];
    for (Circle *c1 in balls) {
        if ([c1.number isEqualToNumber:@(balls.count)]) {
            c1.shouldRemove = YES;
            [b2R addObject:c1];
        }
    }
    
    return b2R;
}

-(NSInteger)indexOfBall:(Circle *)ball inverted:(BOOL)inverted {
    if (inverted) return [[[balls reverseObjectEnumerator] allObjects] indexOfObject:ball];
    return [balls indexOfObject:ball];
}

-(Circle *)ballAtRow:(NSNumber *)row {
    NSArray *inverted = [[balls reverseObjectEnumerator] allObjects];
    if (inverted.count > row.integerValue) {
        Circle *c = inverted[row.integerValue];
        return c;
    }
    return nil;
}

@end
