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

@property (nonatomic, strong) IBOutlet UIButton *btnNewGame;
@property (nonatomic, strong) IBOutlet UIImageView *logoImageView;

@end

@implementation GameOverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [JMGameManager sharedInstance].demoModeEnabled = YES;
    self.view.userInteractionEnabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:[JMHelpers gameOverNotification] object:nil];
    self.navigationController.navigationBar.hidden = YES;
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.btnNewGame.layer.borderColor = [JMHelpers ghostWhiteColorWithAlpha:@1].CGColor;
    self.btnNewGame.layer.borderWidth = 1.0f;
    //self.btnNewGame.layer.cornerRadius = 5.0f;
    [JMGameManager sharedInstance].demoModeEnabled = YES;
    [self addDropCounter];
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blur];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectView.frame = self.view.frame;
    UIVisualEffectView *vibrancyView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    vibrancyView.frame = self.view.frame;
    [self.view addSubview:effectView];
    [self.view addSubview:vibrancyView];
    [self autoplay];
    [self doLogo];
    
}

-(void)doLogo {
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

-(void)toggleUserInputPause {
    
}

-(void)newGame {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"mainVC"];
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [[JMGameManager sharedInstance] resetGameWithCompletion:^(BOOL finished) {
                [JMGameManager sharedInstance].shouldEndNow = YES;
                [JMGameManager sharedInstance].demoModeEnabled = NO;
                //[self performSelector:@selector(newGame) withObject:nil afterDelay:1];
            }];
}

//-(IBAction)startNewGame:(id)sender {
//    [[JMGameManager sharedInstance] resetGameWithCompletion:^(BOOL finished) {
//        [JMGameManager sharedInstance].shouldEndNow = YES;
//        [self performSelector:@selector(newGame) withObject:nil afterDelay:1];
//    }];
//}

-(void)receivedNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:[JMHelpers gameOverNotification]]) {
        if (self.presentedViewController) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self performSelector:@selector(autoplay) withObject:nil afterDelay:5];
        }
    }
}

@end
