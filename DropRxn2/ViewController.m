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

-(void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:[JMHelpers gameRestartNotification] object:nil];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self restart];
    SWRevealViewController *revealViewController = self.revealViewController;
        if ( revealViewController )
        {
    //        //[self.sidebarButton setTarget: self.revealViewController];
    //        //[self.sidebarButton setAction: @selector( revealToggle: )];
            [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
        }
}

-(void)handleNotification:(NSNotification *)notification {
    [self restart];
}

-(void)restart {
    [JMGameManager sharedInstance].demoModeEnabled = NO;
    [[JMGameManager sharedInstance] updateNextBall];
    [self removeDropCounter];
    [self addDropCounter];
    [JMGameManager sharedInstance].shouldEndNow = NO;
}

@end
