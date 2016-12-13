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
@property (nonatomic, strong) UILabel *mainScoreLabel;

@end

@implementation ViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [JMAnimationManager sharedInstance].shouldEndNow = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:[JMHelpers gameRestartNotification] object:nil];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
        [self.navigationController.view removeGestureRecognizer:self.navigationController.interactivePopGestureRecognizer];
    [self restart];
    self.mainScoreLabel.hidden = YES;
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
            [[JMGameManager sharedInstance] resetGameWithCompletion:^(BOOL finished) {
                if (finished) {
                    [self performSelector:@selector(resetGame) withObject:nil afterDelay:4];
                }
            }];
            
        }
    }];
}

-(void)resetGame {
    [[NSNotificationCenter defaultCenter] postNotificationName:[JMHelpers gameResetNotificationName] object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    SWRevealViewController *revealViewController = self.revealViewController;
        if ( revealViewController )
        {
    //        //[self.sidebarButton setTarget: self.revealViewController];
    //        //[self.sidebarButton setAction: @selector( revealToggle: )];
            [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
        }
    
}

-(void)handleGameOver {
    [self doGameOver];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self resetScoreBoard];
    self.mainScoreLabel.text = @"0";
    self.mainScoreLabel.hidden = NO;
    [JMAnimationManager sharedInstance].shouldEndNow = NO;
}

-(void)resetScoreBoard {
    [self.scoreboardView removeFromSuperview];
    self.scoreboardView = nil;
    self.scoreboardView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame)-([JMHelpers columnsWidth]/2),
                                                                   20,
                                                                   [JMHelpers columnsWidth],
                                                                   (CGRectGetHeight(self.view.frame)-[JMHelpers columnHeight])/3)];
    self.scoreboardView.layer.borderColor = [JMHelpers ghostWhiteColorWithAlpha:@1].CGColor;
    self.scoreboardView.layer.borderWidth = 1.0;
    self.scoreboardView.layer.cornerRadius = 5.0;
    [self.view addSubview:self.scoreboardView];
    [self.view sendSubviewToBack:self.scoreboardView];
    
    self.mainScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0, CGRectGetWidth(self.scoreboardView.frame)-20, CGRectGetHeight(self.scoreboardView.frame)/3)];
    [self.mainScoreLabel setFont:[UIFont systemFontOfSize:25.0 weight:UIFontWeightThin]];
    [self.mainScoreLabel setTextAlignment:NSTextAlignmentRight];
    [self.mainScoreLabel setTextColor:[JMHelpers jmTealColor]];
    self.mainScoreLabel.backgroundColor = [UIColor clearColor];
    self.mainScoreLabel.text = @"0";
    [self.scoreboardView addSubview:self.mainScoreLabel];
}

-(void)scoreUpdated {
    NSNumber *score = [JMGameManager sharedInstance].currentScore;
    NSString *scoreString = [NSNumberFormatter localizedStringFromNumber:score numberStyle:NSNumberFormatterDecimalStyle];
    self.mainScoreLabel.text = scoreString;
}



-(void)handleNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:[JMHelpers gameRestartNotification]]) {
        [self restart];
        self.mainScoreLabel.text = @"0";
        self.mainScoreLabel.hidden = NO;
        [JMAnimationManager sharedInstance].shouldEndNow = NO;
    } else if ([notification.name isEqualToString:[JMHelpers gameOverNotification]]) {
        
    }
}


-(void)restart {
    [JMAnimationManager sharedInstance].shouldEndNow = YES;
    [[JMGameManager sharedInstance] resetGameWithCompletion:^(BOOL finished) {
        if (finished) {
            [JMGameManager sharedInstance].demoModeEnabled = NO;
            [[JMGameManager sharedInstance] updateNextBall];
            [[JMGameManager sharedInstance].dropCounter resetDrops];
            [self resetScoreBoard];
        }
    }];
    
}

@end
