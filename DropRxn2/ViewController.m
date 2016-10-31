//
//  ViewController.m
//  DropRXN2
//
//  Created by James Mundie on 10/26/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//
#import "ViewController.h"
#import "DropCounter.h"

@interface ViewController ()

{
    Circle *nextBall;
    DropCounter *dc;
}

@end

@implementation ViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleUserInputPause) name:[JMHelpers toggleUserInputPauseNotification] object:nil];
    [self resetGame];
}

-(void)addColumns {
    for (int i=0; i<[JMHelpers numColumns].intValue; i++) {
        CGPoint gridBeginPoint = CGPointMake(CGRectGetMidX(self.view.bounds)-([JMHelpers columnsWidth]/2),
                                             CGRectGetMidY(self.view.bounds)-([JMHelpers columnHeight]/2));
        Column *column = [[Column alloc] initWithFrame:[JMHelpers calculateColumnFrameAtPoint:gridBeginPoint offset:i]];
        column.columnNumber = @(i);
        [self.view addSubview:column];
        [[JMAnimationManager sharedInstance] addColumn:column];
    }
}

-(void)toggleUserInputPause {
    self.view.userInteractionEnabled = !self.view.userInteractionEnabled;
}

-(void)resetGame {
    if ([[JMAnimationManager sharedInstance] columns].count > 0) {
        [[JMAnimationManager sharedInstance] removeAllColumns];
    }
    [self addColumns];
    [self addNextBall];
    dc = [[DropCounter alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.bounds)-([JMHelpers columnsWidth]/2), CGRectGetMidY(self.view.bounds)+([JMHelpers columnHeight]/2)+3, [JMHelpers columnsWidth], 10)];
    [self.view addSubview:dc];
    [JMAnimationManager sharedInstance].dropCounter = dc;
}

-(void)addNextBall {
    CGFloat circleRadius = [JMHelpers circleRadius];
    Circle *myNextBall = [[Circle alloc] initWithFrame:CGRectMake(30, 30, circleRadius, circleRadius) borderWidth:[JMHelpers borderWidth]];
    myNextBall.number = @([JMHelpers random]);
    nextBall = myNextBall;
    [self.view addSubview:myNextBall];
}

-(void)addRow:(NSInteger)currentDrop {
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if ([touch.view isKindOfClass:[Column class]]) {
        for (Column *col in [JMAnimationManager sharedInstance].columns) {
            if (CGRectIntersectsRect(touch.view.frame, col.frame)) {
                col.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:0.75];
                [col addBallWithNumber:nextBall.number];
                [nextBall removeFromSuperview];
                [self addNextBall];
                
            }
        }
    }
}

@end
