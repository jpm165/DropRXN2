//
//  ViewController.m
//  DropRXN2
//
//  Created by James Mundie on 10/26/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//
#import "ViewController.h"

@interface ViewController ()

{
    BOOL isGameStarting;
}

@end

@implementation ViewController

-(void)viewWillAppear:(BOOL)animated {
    [JMAnimationManager sharedInstance].demoModeEnabled = NO;
    [super viewWillAppear:animated];
    isGameStarting = YES;
    [self performSelector:@selector(unfreezeGame) withObject:nil afterDelay:5];
}

-(void)unfreezeGame {
    if (isGameStarting && self.view.userInteractionEnabled==NO) {
        self.view.userInteractionEnabled = YES;
        isGameStarting = NO;
    }
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
