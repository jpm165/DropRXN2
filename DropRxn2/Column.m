//
//  Column.m
//  DropRXN2
//
//  Created by James Mundie on 10/26/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "Column.h"
#import "GridBox.h"
#import "UIView+RZViewActions.h"
#import "ScoreSprite.h"
#import <QuartzCore/QuartzCore.h>
@interface Column ()

{
    NSMutableArray *balls;
    UIBezierPath *borderPath;
    NSMutableArray *gridBoxes;
}

@end

@implementation Column

-(void)reset {
    [self removeFromSuperview];
    [balls removeAllObjects];
    for (UIView __strong *view in self.subviews) {
        if ([view isKindOfClass:[Circle class]]) {
            [CATransaction begin];
            [view.layer removeAllAnimations];
            [CATransaction commit];
            [view removeFromSuperview];
            view = nil;
        }
    }
}
-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        balls = [NSMutableArray arrayWithCapacity:[JMHelpers numballs].integerValue];
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor clearColor];
        [self addGrid];
    }
    return self;
}

-(void)addGrid {
    if (!gridBoxes) gridBoxes = [NSMutableArray array];
    for (int i=0; i<[JMHelpers numballs].integerValue; i++) {
        GridBox *gb = [[GridBox alloc] initWithFrame:CGRectMake(0, [JMHelpers circleRadius]*i, [JMHelpers circleRadius], [JMHelpers circleRadius])];
        gb.backgroundColor = [UIColor clearColor];
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

-(void)autoAddBallWithNumber:(NSNumber *)number {
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


-(RZViewAction *)addBallWithNumber:(NSNumber *)number {
    if (balls.count == [JMHelpers numballs].integerValue) return nil;
    CGPoint startPoint = CGPointMake(-(self.columnNumber.integerValue*[JMHelpers circleRadius]), -[JMHelpers circleRadius]);
    Circle *circle = [[Circle alloc] initWithFrame:CGRectMake(startPoint.x, startPoint.y, [JMHelpers circleRadius], [JMHelpers circleRadius]) borderWidth:[JMHelpers borderWidth]];
    [circle setNumber:number];
    circle.columnNumber = self.columnNumber;
    circle.initialSlot = @(-1);
    [balls insertObject:circle atIndex:0];
    [self addSubview:circle];
    
    CGRect newframe = CGRectMake(0, -[JMHelpers circleRadius], [JMHelpers circleRadius], [JMHelpers circleRadius]);
    RZViewAction *moveAction = [RZViewAction action:^{
        circle.frame = newframe;
    } withOptions:UIViewAnimationOptionCurveEaseOut duration:0.25];
    return moveAction;
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

-(void)removeScoreSprites {
    for (UIView __strong *view in self.subviews) {
        if ([view isKindOfClass:[ScoreSprite class]]) {
            [view removeFromSuperview];
            view = nil;
        }
    }
}

-(RZViewAction *)addScoreSpriteForBall:(Circle *)ball {
    NSNumber *multiplier = @([JMGameManager sharedInstance].chainCount);
    ScoreSprite *ss = [[ScoreSprite alloc] initWithFrame:ball.frame number:multiplier];
    ss.alpha = 0;
    [self addSubview:ss];
    CGRect oldFrame = ss.frame;
    CGRect newframe = CGRectMake(CGRectGetMinX(ss.frame)-7, CGRectGetMinY(ss.frame)-7, CGRectGetWidth(ss.frame)+14, CGRectGetHeight(ss.frame)+14);
    RZViewAction *fadein = [RZViewAction action:^{
        ss.alpha = 1.0;
    } withDuration:0.25];
    RZViewAction *growAction = [RZViewAction action:^{
        ss.frame = newframe;
    } withDuration:0.25];
    RZViewAction *fadeGrow = [RZViewAction group:@[fadein, growAction]];
    RZViewAction *shrinkAction = [RZViewAction action:^{
        ss.frame = oldFrame;
    } withDuration:0.2];
    RZViewAction *fadeout = [RZViewAction action:^{
        ss.alpha = 0;
    } withDuration:0.2];
    RZViewAction *shrinkFade = [RZViewAction group:@[shrinkAction, fadeout]];
    RZViewAction *sequence = [RZViewAction sequence:@[fadeGrow, shrinkFade]];
    return sequence;
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

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (balls.count==[JMHelpers numballs].integerValue) return;
    if ([JMAnimationManager sharedInstance].isAnimating) return;
    if ([JMGameManager sharedInstance].demoModeEnabled) return;
    
    [[[JMGameManager sharedInstance] activeGameController] hideNextBall];
        self.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:0.75];
    RZViewAction *moveAction = [self addBallWithNumber:[[JMGameManager sharedInstance] currentNextBall].number];
        RZViewAction *bgColorChange = [RZViewAction action:^{
            self.backgroundColor = [UIColor whiteColor];
        } withDuration:0.1];
    [UIView rz_runAction:moveAction withCompletion:^(BOOL finished) {
        if (finished) {
            [UIView rz_runAction:bgColorChange withCompletion:^(BOOL finished) {
                if (finished) {
                    [[JMGameManager sharedInstance] updateNextBall];
                    [JMGameManager sharedInstance].chainCount = 0;
                    [[JMAnimationManager sharedInstance] doDrops];
                }
            }];
        }
    }];

}

@end
