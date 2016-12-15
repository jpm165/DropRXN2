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

@interface ViewController () <SWRevealViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *gameOverImageView;
@property (nonatomic, strong) UIView *scoreboardView;
@property (nonatomic, strong) UILabel *mainScoreLabel;
@property (nonatomic, strong) UILabel *bestScoreLabel;
@property (nonatomic, strong) UILabel *mostChainsLabel;
@property (nonatomic, strong) UILabel *currentChainCountLabel;
@property (nonatomic, strong) UILabel *levelUpLabel;


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
            revealViewController.delegate = self;
    //        //[self.sidebarButton setTarget: self.revealViewController];
    //        //[self.sidebarButton setAction: @selector( revealToggle: )];
            [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
        }
    
}

-(void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position {
    NSLog(@"will move to position");
    switch (position) {
        case FrontViewPositionRight:
            self.gameView.userInteractionEnabled = NO;
            break;
        case FrontViewPositionLeft:
            self.gameView.userInteractionEnabled = YES;
            break;
        default:
            break;
    }
}

-(void)handleGameOver {
    [self doGameOver];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self resetScoreBoard];
    self.mainScoreLabel.hidden = NO;
    [JMAnimationManager sharedInstance].shouldEndNow = NO;
    [self.revealViewController revealToggleAnimated:YES];
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
    self.mainScoreLabel.text = @"score: 0";
    [self.scoreboardView addSubview:self.mainScoreLabel];
    
    self.bestScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetHeight(self.scoreboardView.frame)/3, CGRectGetWidth(self.scoreboardView.frame)-20, CGRectGetHeight(self.scoreboardView.frame)/3)];
    self.bestScoreLabel.backgroundColor = [UIColor clearColor];
    [self.bestScoreLabel setFont:[UIFont systemFontOfSize:25.0 weight:UIFontWeightThin]];
    [self.bestScoreLabel setTextAlignment:NSTextAlignmentRight];
    [self.bestScoreLabel setTextColor:[JMHelpers jmRedColor]];
    NSString *best = [[JMGameManager sharedInstance] getHighScore].stringValue;
    self.bestScoreLabel.text = [NSString stringWithFormat:@"best: %@", best];
    [self.scoreboardView addSubview:self.bestScoreLabel];
    
    self.mostChainsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetHeight(self.scoreboardView.frame)-CGRectGetHeight(self.scoreboardView.frame)/3, CGRectGetWidth(self.scoreboardView.frame)-20, CGRectGetHeight(self.scoreboardView.frame)/3)];
    self.mostChainsLabel.backgroundColor = [UIColor clearColor];
    [self.mostChainsLabel setFont:[UIFont systemFontOfSize:20 weight:UIFontWeightLight]];
    [self.mostChainsLabel setTextAlignment:NSTextAlignmentRight];
    [self.mostChainsLabel setTextColor:[UIColor grayColor]];
    NSNumber *mostChains = [[JMGameManager sharedInstance] getBestChainCount];
    NSString *bestChainString = [NSNumberFormatter localizedStringFromNumber:mostChains numberStyle:NSNumberFormatterDecimalStyle];
    NSString *mostChainsStr = [NSString stringWithFormat:@"rxn: 0x0%@", bestChainString];
    self.mostChainsLabel.text = mostChainsStr;
    [self.scoreboardView addSubview:self.mostChainsLabel];
    
    self.currentChainCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(self.scoreboardView.frame)+12.5, CGRectGetWidth(self.view.frame)-60, 50)];
    self.currentChainCountLabel.backgroundColor = [UIColor clearColor];
    self.currentChainCountLabel.textAlignment = NSTextAlignmentCenter;
    self.currentChainCountLabel.text = @"rxn: 0x02";
    [self.currentChainCountLabel setTextColor:[JMHelpers jmRedColor]];
    self.currentChainCountLabel.alpha = 0.0;
    [self.currentChainCountLabel setFont:[UIFont fontWithName:@"RepublikaII" size:40]];
    if (![self.view.subviews containsObject:self.currentChainCountLabel]) [self.view addSubview:self.currentChainCountLabel];
    
    self.levelUpLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(self.currentChainCountLabel.frame)+10, CGRectGetWidth(self.view.frame)-60, 50)];
    self.levelUpLabel.backgroundColor = [UIColor clearColor];
    self.levelUpLabel.textAlignment = NSTextAlignmentCenter;
    self.levelUpLabel.text = @"LEVEL UP!";
    [self.levelUpLabel setTextColor:[JMHelpers jmDarkOrangeColor]];
    self.levelUpLabel.alpha = 0.0;
    [self.levelUpLabel setFont:[UIFont fontWithName:@"RepublikaII" size:40]];
    if (![self.view.subviews containsObject:self.levelUpLabel]) [self.view addSubview:self.levelUpLabel];

    
}

-(void)gotBestChain:(NSNumber *)chainCount {
    NSString *str = [NSString stringWithFormat:@"rxn: 0x0%@", chainCount.stringValue];
    self.currentChainCountLabel.text = str;
    RZViewAction *unfadeAction = [RZViewAction action:^{
        self.currentChainCountLabel.alpha = 0.75;
    } withOptions:UIViewAnimationOptionCurveEaseIn duration:0.5];
    RZViewAction *wait = [RZViewAction waitForDuration:0.5];
    RZViewAction *fadeAction = [RZViewAction action:^{
        self.currentChainCountLabel.alpha = 0.0;
    } withOptions:UIViewAnimationOptionCurveEaseOut duration:0.5];
    [UIView rz_runAction:[RZViewAction sequence:@[unfadeAction, fadeAction]]];
    
    //self.currentChainCountLabel.alpha = 1;
}

-(void)scoreUpdated {
    NSNumber *score = [JMGameManager sharedInstance].currentScore;
    NSString *scoreString = [NSNumberFormatter localizedStringFromNumber:score numberStyle:NSNumberFormatterDecimalStyle];
    NSString *scoreStr = [NSString stringWithFormat:@"score: %@", scoreString];
    self.mainScoreLabel.text = scoreStr;
    
    NSNumber *highscore = [[JMGameManager sharedInstance] getHighScore];
    NSString *highscoreString = [NSNumberFormatter localizedStringFromNumber:highscore numberStyle:NSNumberFormatterDecimalStyle];
    NSString *highscoreStr = [NSString stringWithFormat:@"best: %@", highscoreString];
    self.bestScoreLabel.text = highscoreStr;
    
    NSNumber *mostChains = [[JMGameManager sharedInstance] getBestChainCount];
    NSString *bestChainString = [NSNumberFormatter localizedStringFromNumber:mostChains numberStyle:NSNumberFormatterDecimalStyle];
    NSString *mostChainsStr = [NSString stringWithFormat:@"rxn: 0x0%@", bestChainString];
    self.mostChainsLabel.text = mostChainsStr;
}

-(void)updateLevel:(NSNumber *)level {
    NSString *text = [NSString stringWithFormat:@"LVL: 0x%02d", level.intValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.lvlLabel2.text = text;
        RZViewAction *unfadeAction = [RZViewAction action:^{
            self.levelUpLabel.alpha = 0.75;
        } withOptions:UIViewAnimationOptionCurveEaseIn duration:0.5];
        RZViewAction *wait = [RZViewAction waitForDuration:0.5];
        RZViewAction *fadeAction = [RZViewAction action:^{
            self.levelUpLabel.alpha = 0.0;
        } withOptions:UIViewAnimationOptionCurveEaseOut duration:0.5];
        [UIView rz_runAction:[RZViewAction sequence:@[unfadeAction, wait, fadeAction]]];
    });
}


-(void)handleNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:[JMHelpers gameRestartNotification]]) {
        [self restart];
        self.mainScoreLabel.text = @"score: 0";
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
            [self removeDropCounter];
            [self addDropCounter];
            [[JMGameManager sharedInstance].dropCounter resetDrops];
            [self resetScoreBoard];
        }
    }];
    
}

@end
