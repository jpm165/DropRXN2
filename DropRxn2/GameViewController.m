//
//  GameViewController.m
//  DropRxn2
//
//  Created by James Mundie on 11/2/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "GameViewController.h"

@interface GameViewController ()

@end

@implementation GameViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self resetGame];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleUserInputPause) name:[JMHelpers toggleUserInputPauseNotification] object:nil];
    //[self addColumns];
    //[self addNextBall];
    
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

-(void)removeAllBalls {
    for (int i=0; i<self.view.subviews.count; i++) {
        UIView *view = self.view.subviews[i];
        if ([view isKindOfClass:[Circle class]]) {
            [view removeFromSuperview];
            view = nil;
        }

    }
}

-(void)removeEffectViews {
    for (int i=0; i<self.view.subviews.count; i++) {
        UIView *view = self.view.subviews[i];
        if ([view isKindOfClass:[UIVisualEffectView class]]) {
            [view removeFromSuperview];
            view = nil;
        }
        
    }
}

-(void)addNextBall {
    CGFloat circleRadius = [JMHelpers circleRadius];
    Circle *myNextBall = [[Circle alloc] initWithFrame:CGRectMake(30, 30, circleRadius, circleRadius) borderWidth:[JMHelpers borderWidth]];
    myNextBall.number = @([JMHelpers random]);
    if (nextBall) {
        [nextBall removeFromSuperview];
        nextBall = nil;
    }
    nextBall = myNextBall;
    [self.view addSubview:myNextBall];
}

-(void)toggleUserInputPause {
    
    if ([JMAnimationManager sharedInstance].demoModeEnabled) return;
    NSLog(@"user interaction toggles");
    self.view.userInteractionEnabled = !self.view.userInteractionEnabled;
}

-(void)resetGame {
    if ([[JMAnimationManager sharedInstance] columns].count > 0) {
        [[JMAnimationManager sharedInstance] removeAllColumns];
    }
    [self addColumns];
    [self removeAllBalls];
    [self addNextBall];
    
    [self removeEffectViews];
    
    if (dc) {
        [dc removeFromSuperview];
        dc = nil;
    }
    dc = [[DropCounter alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.bounds)-([JMHelpers columnsWidth]/2), CGRectGetMidY(self.view.bounds)+([JMHelpers columnHeight]/2)+3, [JMHelpers columnsWidth], 10)];
    [self.view addSubview:dc];
    [JMAnimationManager sharedInstance].dropCounter = dc;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
