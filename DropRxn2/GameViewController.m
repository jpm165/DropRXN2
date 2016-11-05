//
//  GameViewController.m
//  DropRxn2
//
//  Created by James Mundie on 11/2/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "GameViewController.h"
#import "SWRevealViewController.h"

@interface GameViewController ()

{
    Circle *nextBall;
    DropCounter *dc;
}



@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addGameView];
    [JMGameManager sharedInstance].activeGameController = self;
    [[JMGameManager sharedInstance] resetGameWithCompletion:^(BOOL finished) {
        //[self addDropCounter];
    }];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![self.view.subviews containsObject:self.gameView]) {
        [self.view addSubview:self.gameView];
    }
}

-(void)addGameView {
    CGPoint gridBeginPoint = CGPointMake(CGRectGetMidX(self.view.bounds)-([JMHelpers columnsWidth]/2),
                                             CGRectGetMidY(self.view.bounds)-([JMHelpers columnHeight]/2));
    CGRect newframe = CGRectMake(gridBeginPoint.x, gridBeginPoint.y, [JMHelpers columnsWidth], [JMHelpers columnHeight]);
    UIView *view = [[UIView alloc] initWithFrame:newframe];
    view.backgroundColor = [UIColor clearColor];
    self.gameView = view;
    [[JMGameManager sharedInstance] setGameView:self.gameView];
}

-(void)hideNextBall {
    nextBall.hidden = YES;
}

-(void)scoreUpdated {
    
}


-(void)addNextBall {
    CGFloat circleRadius = [JMHelpers circleRadius];
    Circle *myNextBall = [[JMGameManager sharedInstance] currentNextBall];
    myNextBall.frame = CGRectMake(CGRectGetMinX(self.gameView.frame), CGRectGetMinY(self.gameView.frame)-circleRadius, circleRadius, circleRadius);
    if (nextBall) {
        [nextBall removeFromSuperview];
        nextBall = nil;
    }
    nextBall = myNextBall;
    nextBall.number = myNextBall.number;
    [self.view addSubview:myNextBall];
    
    int counter = 0;
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[Circle class]]) {
            counter++;
        }
    }
    NSLog(@"Number of balls in GameViewController: %d", counter);
}

-(void)addDropCounter {
    [self removeDropCounter];
    dc = [[DropCounter alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.bounds)-([JMHelpers columnsWidth]/2), CGRectGetMidY(self.view.bounds)+([JMHelpers columnHeight]/2)+3, [JMHelpers columnsWidth], 10)];
    [self.view addSubview:dc];
    [JMGameManager sharedInstance].dropCounter = dc;
    if (![JMGameManager sharedInstance].demoModeEnabled) [dc resetDrops];
}

-(void)removeDropCounter {
    [dc removeFromSuperview];
    [JMGameManager sharedInstance].dropCounter = nil;
    dc = nil;
}

@end
