//
//  ViewController.m
//  DropRXN2
//
//  Created by James Mundie on 10/26/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//
#import "ViewController.h"
#import "SWRevealViewController.h"
#import "UIView+RZViewActions.h"

@interface ViewController ()

@property (nonatomic, strong) IBOutlet UIImageView *gameOverImageView;
@property (nonatomic, strong) UIView *scoreboardView;

@end

@implementation ViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:[JMHelpers gameRestartNotification] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:[JMHelpers gameOverNotification] object:nil];
    
}

-(void)doGameOver {
    self.view.userInteractionEnabled = NO;
    self.gameOverImageView.hidden = NO;
    [self.view bringSubviewToFront:self.gameOverImageView];
    RZViewAction *wait = [RZViewAction waitForDuration:0.75];
    CGRect newframe = CGRectMake(CGRectGetMinX(self.gameOverImageView.frame), CGRectGetMidY(self.view.frame)-CGRectGetHeight(self.gameOverImageView.frame)/2, CGRectGetWidth(self.gameOverImageView.frame), CGRectGetHeight(self.gameOverImageView.frame));
    RZViewAction *move = [RZViewAction springAction:^{
        self.gameOverImageView.frame = newframe;
    } withDamping:0.5 initialVelocity:2.0 options:UIViewAnimationOptionCurveEaseInOut duration:0.75];
    [UIView rz_runAction:[RZViewAction sequence:@[wait, move, wait]] withCompletion:^(BOOL finished) {
        if (finished) {
            [self performSelector:@selector(resetGame) withObject:nil afterDelay:4];
        }
    }];
}

-(void)resetGame {
    [[NSNotificationCenter defaultCenter] postNotificationName:[JMHelpers gameResetNotificationName] object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.scoreboardView.frame = CGRectMake(CGRectGetMidX(self.view.frame)-([JMHelpers columnsWidth]/2),
                                           20,
                                           [JMHelpers columnsWidth],
                                           (CGRectGetHeight(self.view.frame)-[JMHelpers columnHeight])/3);
    self.scoreboardView.layer.borderColor = [UIColor blackColor].CGColor;
    self.scoreboardView.layer.borderWidth = 10.0;
    [self.view addSubview:self.scoreboardView];
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
    if ([notification.name isEqualToString:[JMHelpers gameRestartNotification]]) {
        [self restart];
    } else if ([notification.name isEqualToString:[JMHelpers gameOverNotification]]) {
        [self doGameOver];
    }
}

-(void)restart {
    [JMGameManager sharedInstance].demoModeEnabled = NO;
    [[JMGameManager sharedInstance] updateNextBall];
    [self removeDropCounter];
    [self addDropCounter];
    [JMGameManager sharedInstance].shouldEndNow = NO;
}

@end
