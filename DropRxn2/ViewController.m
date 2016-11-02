//
//  ViewController.m
//  DropRXN2
//
//  Created by James Mundie on 10/26/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//
#import "ViewController.h"

@implementation ViewController

-(void)viewWillAppear:(BOOL)animated {
    [JMAnimationManager sharedInstance].demoModeEnabled = NO;
    [super viewWillAppear:animated];
    [self performSelector:@selector(toggleUserInputPause) withObject:nil afterDelay:2];
    
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
