//
//  ViewController.m
//  DropRXN2
//
//  Created by James Mundie on 10/26/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//
#import "ViewController.h"
#import "SWRevealViewController.h"

@implementation ViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addNextBall];
    [self addDropCounter];
    [JMGameManager sharedInstance].shouldEndNow = NO;
    
}

@end
