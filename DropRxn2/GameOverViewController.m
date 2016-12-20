
//
//  GameOverViewController.m
//  DropRxn2
//
//  Created by James Mundie on 10/29/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "GameOverViewController.h"
#import "JMHelpers.h"
#import "ViewController.h"
#import "UIView+RZViewActions.h"

@interface GameOverViewController ()

{
    UIVisualEffectView *effectView;
    UIVisualEffectView *vibrancyView;
    BOOL shouldNotDoAutoplay;
}

@property (nonatomic, strong) UIButton *btnNewGame;
@property (nonatomic, strong) UIImageView *logoImageView;


@end

@implementation GameOverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.userInteractionEnabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:[JMHelpers gameResetNotificationName] object:nil];
    self.navigationController.navigationBar.hidden = YES;
    self.logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"droprxnLogo_transparent"]];
    self.logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.logoImageView];
    self.btnNewGame = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnNewGame setTitle:@"new game" forState:UIControlStateNormal];
    [self.btnNewGame.titleLabel setFont:[UIFont fontWithName:@"RepublikaII" size:20]];
    [self.btnNewGame addTarget:self action:@selector(doNewGameSegue:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnNewGame];
    self.btnNewGame.layer.borderColor = [JMHelpers ghostWhiteColorWithAlpha:@1].CGColor;
    self.btnNewGame.layer.borderWidth = 1.0f;
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectView.backgroundColor = [UIColor clearColor]; //[JMHelpers ghostWhiteColorWithAlpha:@(0.1)];
    [JMGameManager sharedInstance].demoModeEnabled = YES;
    [self addDropCounter];
    [[JMGameManager sharedInstance] resetGameWithCompletion:^(BOOL finished) {
        if (finished) {
            [self performSelector:@selector(doAutoplay) withObject:nil afterDelay:4];
        }
    }];
    
    
    
}

-(void)animateTitleColor {
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionFade;
    transition.duration = 1;
    [self.btnNewGame.layer addAnimation:transition forKey:kCATransition];
    [self.btnNewGame setTitle:@"new game" forState:UIControlStateNormal];
    [self.btnNewGame setTitleColor:[JMHelpers jmRedColor] forState:UIControlStateNormal];
}

-(IBAction)doNewGameSegue:(id)sender {
    shouldNotDoAutoplay = YES;
    [JMAnimationManager sharedInstance].shouldEndNow = YES;
    [[JMGameManager sharedInstance] resetGameWithCompletion:^(BOOL finished) {
        if (finished) {
            int colcount = 0;
            int ballcount = 0;
            for (UIView *colview in self.gameView.subviews) {
                if ([colview isKindOfClass:[Column class]]) {
                    colcount++;
                    for (UIView *ballview in colview.subviews) {
                        if ([ballview isKindOfClass:[Circle class]]) {
                            ballcount++;
                        }
                    }
                }
            }
            NSLog(@"After reset: %d cols with %d balls", colcount, ballcount);
            [self performSegueWithIdentifier:@"newgamesegue" sender:nil];
        }
    }];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    shouldNotDoAutoplay = NO;
    effectView.frame = self.view.frame;
    vibrancyView.frame = self.view.frame;
    if (![self.view.subviews containsObject:self.gameView]) [self.view addSubview:self.gameView];
    if (![self.view.subviews containsObject:effectView]) [self.view addSubview:effectView];
    [self.view bringSubviewToFront:effectView];
    [self.btnNewGame setTitleColor:[JMHelpers jmRedColor] forState:UIControlStateNormal];
    [self.btnNewGame setTitleColor:[JMHelpers jmTealColor] forState:UIControlStateHighlighted];
    if (![self.view.subviews containsObject:self.btnNewGame]) [self.view addSubview:_btnNewGame];
    
    [self doLogo];
    [JMAnimationManager sharedInstance].shouldEndNow = NO;
    
}

-(void)handleGameOver {
    
    [[JMGameManager sharedInstance] resetGameWithCompletion:^(BOOL finished) {
        if (finished) {
            //[self.gameView removeFromSuperview];
            //self.gameView = [JMGameManager sharedInstance].getGameView;
            if (![self.view.subviews containsObject:self.gameView]) [self.view addSubview:self.gameView];
            [self doLogo];
            [self performSelector:@selector(doAutoplay) withObject:nil afterDelay:2];
        }
    }];
}

-(void)doLogo {
    NSLog(@"Do logo.");
    self.logoImageView.frame = CGRectMake(0, -102, CGRectGetWidth(self.view.frame), 102);
    self.btnNewGame.frame = CGRectMake(CGRectGetMidX(self.view.frame)-CGRectGetWidth(self.view.frame)/6, CGRectGetMaxY(self.view.frame), CGRectGetWidth(self.view.frame)/3, 33);
    [self.view bringSubviewToFront:self.gameView];
    [self.view bringSubviewToFront:effectView];
    [self.view bringSubviewToFront:self.logoImageView];
    [self.view bringSubviewToFront:self.btnNewGame];
    RZViewAction *wait = [RZViewAction waitForDuration:1.5];
    RZViewAction *logoMove = [RZViewAction springAction:^{
        CGRect newFrame = CGRectMake(CGRectGetMinX(self.logoImageView.frame), CGRectGetMidY(self.view.frame)-CGRectGetHeight(self.logoImageView.frame), self.logoImageView.frame.size.width, self.logoImageView.frame.size.height);
        self.logoImageView.frame = newFrame;
    } withDamping:0.5 initialVelocity:2.0 options:UIViewAnimationOptionCurveEaseInOut duration:0.75];
    RZViewAction *btnMove = [RZViewAction springAction:^{
        CGRect newFrame = CGRectMake(CGRectGetMinX(self.btnNewGame.frame), CGRectGetMidY(self.view.frame)+(CGRectGetHeight(self.btnNewGame.frame)), CGRectGetWidth(self.btnNewGame.frame), CGRectGetHeight(self.btnNewGame.frame));
        self.btnNewGame.frame = newFrame;
    } withDamping:0.5 initialVelocity:2.0 options:UIViewAnimationOptionCurveEaseInOut duration:0.75];
    RZViewAction *wait2 = [RZViewAction waitForDuration:0.1];
    [UIView rz_runAction:[RZViewAction sequence:@[wait, logoMove, wait2, btnMove]]];
    self.btnNewGame.userInteractionEnabled = YES;
    
}


-(void)autoplay {
    [[JMGameManager sharedInstance] resetGameWithCompletion:^(BOOL finished) {
        if (finished) {
            int random = arc4random_uniform((int)[[JMGameManager sharedInstance] getColumns].count-1);
            Column *col = [[JMGameManager sharedInstance] getColumns][random];
            col.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:0.75];
            [col autoAddBallWithNumber:[[JMGameManager sharedInstance] currentNextBall].number];
        }
    }];
}

-(void)doAutoplay {
    if (shouldNotDoAutoplay) return;
    [JMAnimationManager sharedInstance].shouldEndNow = NO;
    int random = arc4random_uniform((int)[[JMGameManager sharedInstance] getColumns].count-1);
    Column *col = [[JMGameManager sharedInstance] getColumns][random];
    col.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:0.75];
    [col autoAddBallWithNumber:[[JMGameManager sharedInstance] currentNextBall].number];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
//    [[JMGameManager sharedInstance] resetGameWithCompletion:^(BOOL finished) {
//        if (finished) NSLog(@"finished");
//                //[self performSelector:@selector(newGame) withObject:nil afterDelay:1];
//            }];
}

-(void)receivedNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:[JMHelpers gameResetNotificationName]]) {
        //[[JMGameManager sharedInstance] resetGameWithCompletion:^(BOOL finished) {
            //if (finished) {
                [JMGameManager sharedInstance].demoModeEnabled = YES;
                [self.navigationController popViewControllerAnimated:YES];
                [self.gameView removeFromSuperview];
                //[self removeDropCounter];
                [[JMGameManager sharedInstance].dropCounter resetDrops];
                self.gameView = [JMGameManager sharedInstance].getGameView;
                [self.view addSubview:self.gameView];
                [self doLogo];
                [self performSelector:@selector(doAutoplay) withObject:nil afterDelay:3];
            //}
        //}];
        
    }
}

@end
