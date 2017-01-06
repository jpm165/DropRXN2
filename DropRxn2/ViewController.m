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
#import "JMHelpers.h"
#import "PowerUpSelector.h"
#import "PowerUp.h"
#import "PowerUpPopoverInfoAndSelectViewController.h"



@interface ViewController () <SWRevealViewControllerDelegate, UIPopoverPresentationControllerDelegate,PowerUpInfoAndSelectProtocol>

@property (nonatomic, strong) UIImageView *gameOverImageView;
@property (nonatomic, strong) UIView *scoreboardView;
@property (nonatomic, strong) UILabel *mainScoreLabel;
@property (nonatomic, strong) UILabel *bestScoreLabel;
@property (nonatomic, strong) UILabel *mostChainsLabel;
@property (nonatomic, strong) UILabel *currentChainCountLabel;
@property (nonatomic, strong) UILabel *levelUpLabel;
@property (nonatomic, strong) UILabel *goLabel;

@property (nonatomic, strong) NSMutableArray *powerUpPassThroughViews;

@property (nonatomic, strong) UIVisualEffectView *blurEffectView;


@property (nonatomic, strong) PowerUpSelector *powerUpSelector;


@end

@implementation ViewController

-(void)isSelected:(id)sender {
    PowerUp *p = (PowerUp *)sender;
    PowerUpPopoverInfoAndSelectViewController *pupiasvc = [self.storyboard instantiateViewControllerWithIdentifier:@"powerUpInfoPopover"];
    pupiasvc.modalPresentationStyle = UIModalPresentationPopover;
    pupiasvc.popoverPresentationController.delegate = self;
    pupiasvc.powerUp = p;
    pupiasvc.popoverPresentationController.sourceView = p;
    pupiasvc.popoverPresentationController.sourceRect = p.bounds;
    pupiasvc.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
    //pupiasvc.view.backgroundColor = [JMHelpers jmTealColor];
    pupiasvc.popoverPresentationController.backgroundColor = [JMHelpers jmOrangeColor];
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blur];
    self.blurEffectView.frame = self.gameView.bounds;
    if (![self.gameView.subviews containsObject:self.blurEffectView]) [self.gameView addSubview:self.blurEffectView];
    [self.view bringSubviewToFront:self.goLabel];
    [self.view bringSubviewToFront:self.powerUpSelector];
    pupiasvc.popoverPresentationController.passthroughViews = self.powerUpPassThroughViews;
    self.isPresentingPopover = YES;
    self.currentlySelectedPowerUp = p;
    [self presentViewController:pupiasvc animated:YES completion:nil];
}

-(void)isDelselected:(id)sender {
    self.isPresentingPopover = NO;
    self.currentlySelectedPowerUp.isPresentingPopover = NO;
    [self dismissViewControllerAnimated:YES completion:^{
        if (sender) [self isSelected:sender];
    }];
}


-(void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    if ([self.gameView.subviews containsObject:self.blurEffectView]) {
        [self.blurEffectView removeFromSuperview];
        self.blurEffectView = nil;
    }
    NSLog(@"did dismiss popover");
}

-(BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    NSLog(@"should dismiss popover");
    return YES;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [JMAnimationManager sharedInstance].shouldEndNow = YES;
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
        [self.navigationController.view removeGestureRecognizer:self.navigationController.interactivePopGestureRecognizer];
    [self changeMode:kGameModeClassic];
    
}

-(void)doPopoverWithContent:(UIViewController *)content {
    
}

-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

-(void)addPassthroughPowerUpView:(id)sender {
    PowerUp *p = (PowerUp *)sender;
    if (!self.powerUpPassThroughViews) self.powerUpPassThroughViews = [@[] mutableCopy];
    if (![self.powerUpPassThroughViews containsObject:p]) [self.powerUpPassThroughViews addObject:p];
    //self.popoverPresentationController.passthroughViews = self.powerUpPassThroughViews;
}

-(void)addPowerUpChooser {
    if (self.powerUpSelector) [self.powerUpSelector removeFromSuperview];
    CGFloat remainingSpace = CGRectGetMaxY(self.view.frame) - CGRectGetMaxY(self.lvlLabel2.frame) - 40;
    CGFloat myHeight = ([JMHelpers circleRadius]+10>remainingSpace) ? [JMHelpers circleRadius]+10 : remainingSpace;
    CGRect powerUpChooserFrame = CGRectMake(CGRectGetMinX(self.scoreboardView.frame), CGRectGetMaxY(self.lvlLabel2.frame)+3, CGRectGetWidth(self.scoreboardView.frame), myHeight);
    self.powerUpSelector = [[PowerUpSelector alloc] initWithFrame:powerUpChooserFrame];
    self.powerUpSelector.backgroundColor = [UIColor clearColor];
    self.powerUpSelector.layer.borderColor = [JMHelpers ghostWhiteColorWithAlpha:@1].CGColor;
    self.powerUpSelector.layer.borderWidth = 1.0;
    self.powerUpSelector.layer.cornerRadius = 5.0;
    [self.view addSubview:self.powerUpSelector];
    self.popoverPresentationController.passthroughViews = @[self.powerUpSelector];
}

-(void)removePowerUpChooser {
    if (self.powerUpSelector) [self.powerUpSelector removeFromSuperview];
    self.powerUpSelector = nil;
}

-(void)startPowerMode {
    RZViewAction *fadeAction = [RZViewAction action:^{
        self.goLabel.alpha = 0;
    } withOptions:UIViewAnimationOptionCurveEaseIn duration:0.5];
    [UIView rz_runAction:[RZViewAction sequence:@[fadeAction]] withCompletion:^(BOOL finished) {
        if (finished) [self doGoLabel];
    }];
}

-(void)changeMode:(GameMode)gameMode {
    self.mainScoreLabel.hidden = YES;
    [self restart];
    switch (gameMode) {
        case kGameModePower:
            [self addPowerUpChooser];
            self.gameView.userInteractionEnabled = NO;
            break;
            
        default:
            break;
    }
}

-(void)doGameOver {
    self.view.userInteractionEnabled = NO;
    self.gameOverImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dgameover_normal"]];
    if (![self.view.subviews containsObject:self.gameOverImageView]) [self.view addSubview:self.gameOverImageView];
    self.gameOverImageView.frame = CGRectMake(0, -102, CGRectGetWidth(self.view.frame), 102);
    self.gameOverImageView.contentMode = UIViewContentModeScaleAspectFit;
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

-(void)chooseLabel {
    if ([JMGameManager sharedInstance].currentGameMode==kGameModePower) {
        [self doSelectPowerUpLabel];
    } else {
        [self doGoLabel];
    }
}

-(void)doLabelWithMessage:(NSString *)message size:(CGFloat)size {
    
    CGSize labelTextSize = [message sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"RepublikaII" size:size]}];
    CGRect boundingBox = [message boundingRectWithSize:CGSizeMake(self.view.bounds.size.width-100, 500) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"RepublikaII" size:size]} context:nil];
    [self.goLabel removeFromSuperview];
    self.goLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame)-boundingBox.size.width/2, CGRectGetMidY(self.view.frame)-boundingBox.size.height/2, boundingBox.size.width, boundingBox.size.height)];
    self.goLabel.text = message;
    self.goLabel.textAlignment = NSTextAlignmentCenter;
    [self.goLabel setFont:[UIFont fontWithName:@"RepublikaII" size:size]];
    self.goLabel.textColor = [JMHelpers jmRedColor];
    self.goLabel.alpha = 0.0;
    self.goLabel.numberOfLines = 0;
    self.goLabel.lineBreakMode = NSLineBreakByWordWrapping;
    if (![self.view.subviews containsObject:self.goLabel]) [self.view addSubview:self.goLabel];
    [self.view bringSubviewToFront:self.goLabel];
}

-(void)addedPowerUp:(BOOL)doneAddingPowerUps {
    NSLog(@"Added powerup");
    [self isDelselected:nil];
    //[self dismissViewControllerAnimated:YES completion:nil];
    RZViewAction *fadeAction = [RZViewAction action:^{
        self.goLabel.alpha = 0;
    } withOptions:UIViewAnimationOptionCurveEaseIn duration:0.5];
    [UIView rz_runAction:[RZViewAction sequence:@[fadeAction]] withCompletion:^(BOOL finished) {
        if (finished && !doneAddingPowerUps) [self doSelectPowerUpLabel];
    }];
    if (doneAddingPowerUps) [self doGoLabel];
    
}

-(void)doSelectPowerUpLabel {
    if (self.isGameOver) return;
    NSString *message = [NSString stringWithFormat:@"Select %lu Power-ups Below...", 3-[JMGameManager sharedInstance].selectedPowerups.count];
    [self doLabelWithMessage:message size:30];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        RZViewAction *unfadeAction = [RZViewAction action:^{
            self.goLabel.alpha = 0.75;
        } withOptions:UIViewAnimationOptionCurveEaseIn duration:0.5];
        [UIView rz_runAction:[RZViewAction sequence:@[unfadeAction]] withCompletion:^(BOOL finished) {
            if (finished) self.gameView.userInteractionEnabled = NO;
        }];
    });
}

-(void)doGoLabel {
    if (self.isGameOver) return;
    [self doLabelWithMessage:@"GO!" size:80];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        RZViewAction *unfadeAction = [RZViewAction action:^{
            self.goLabel.alpha = 0.75;
        } withOptions:UIViewAnimationOptionCurveEaseIn duration:0.5];
        RZViewAction *wait = [RZViewAction waitForDuration:0.5];
        RZViewAction *fadeAction = [RZViewAction action:^{
            self.goLabel.alpha = 0.0;
        } withOptions:UIViewAnimationOptionCurveEaseOut duration:0.5];
        [UIView rz_runAction:[RZViewAction sequence:@[unfadeAction, wait, fadeAction]] withCompletion:^(BOOL finished) {
            if (finished) self.gameView.userInteractionEnabled = YES;
        }];
    });
    
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
            
            [self chooseLabel];
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
    NSString *best = [NSNumberFormatter localizedStringFromNumber:[[JMGameManager sharedInstance] getHighScore] numberStyle:NSNumberFormatterDecimalStyle];
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


-(void)restart {
    [JMAnimationManager sharedInstance].shouldEndNow = YES;
    [self removePowerUpChooser];
    [[JMGameManager sharedInstance] resetGameWithCompletion:^(BOOL finished) {
        if (finished) {
            [JMGameManager sharedInstance].demoModeEnabled = NO;
            [[JMGameManager sharedInstance] updateNextBall];
            [self removeDropCounter];
            [self addDropCounter];
            [[JMGameManager sharedInstance].dropCounter resetDrops];
            [self resetScoreBoard];
            [JMAnimationManager sharedInstance].shouldEndNow = NO;
        }
    }];
    
}

@end
