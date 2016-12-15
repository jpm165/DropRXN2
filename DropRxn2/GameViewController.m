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
}



@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addGameView];
    [JMGameManager sharedInstance].activeGameController = self;
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

-(void)handleGameOver {
    
}

-(void)scoreUpdated {
    
}

-(void)gotBestChain:(NSNumber *)chainCount {
    
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
    
    NSString *text = @"LVL: 0x01";
    CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16 weight:UIFontWeightMedium]}];
    self.lvlLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(dc.frame), CGRectGetMaxY(dc.frame)+3, CGRectGetWidth(self.view.bounds), textSize.height)];
    self.lvlLabel2.textColor = [JMHelpers jmDarkOrangeColor];
    self.lvlLabel2.backgroundColor = [UIColor clearColor];
    [self.lvlLabel2 setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightMedium]];
    self.lvlLabel2.text = text;
    self.lvlLabel2.opaque = NO;
    if (![self.view.subviews containsObject:self.lvlLabel2]) [self.view addSubview:self.lvlLabel2];
}

-(void)removeDropCounter {
    [dc removeFromSuperview];
    [JMGameManager sharedInstance].dropCounter = nil;
    dc = nil;
    
    [self.lvlLabel2 removeFromSuperview];
    self.lvlLabel2 = nil;
}

@end
