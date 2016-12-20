//
//  LeftNavMenuTableViewController.m
//  DropRxn2
//
//  Created by James Mundie on 11/3/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "LeftNavMenuTableViewController.h"
#import "JMHelpers.h"
#import "SWRevealViewController.h"
#import "UIView+RZViewActions.h"
#import "LeftNavMenuTableViewCell.h"
#import "JMGameManager.h"

@interface LeftNavMenuTableViewController ()

{
    NSArray *menuItems, *menuTitles, *altMenuTitles, *normalMenuTitles;
    NSString *restartString;
    GameMode currentGameMode;
    GameDifficulty currentDifficulty;
}

@property (nonatomic, strong) IBOutlet UIImageView *quitGameBtnImageView;

@end

@implementation LeftNavMenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    normalMenuTitles = @[@"quit game", @"restart", @"difficulty", @"mode"];
    menuTitles = [normalMenuTitles copy];
    altMenuTitles = @[@"quit game", @"start", @"difficulty", @"mode"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    menuTitles = [normalMenuTitles copy];
    currentDifficulty = [JMGameManager sharedInstance].currentDifficulty;
    currentGameMode = [JMGameManager sharedInstance].currentGameMode;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return menuTitles.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section != 0) return nil;
    return @"droprxn";
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if (section != 0) return;
    
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.layer.borderColor = [JMHelpers ghostWhiteColorWithAlpha:@1].CGColor;
    header.layer.borderWidth = 1.0;
    header.tintColor = [UIColor clearColor];
    header.textLabel.textColor = [JMHelpers jmRedColor];
    header.textLabel.font = [UIFont fontWithName:@"RepublikaII" size:35.0];
    CGRect headerFrame = header.frame;
    header.textLabel.frame = headerFrame;
    header.textLabel.textAlignment = NSTextAlignmentCenter;
    
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LeftNavMenuTableViewCell *cell;
    NSString *title = menuTitles[indexPath.row];
    cell = (LeftNavMenuTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"menuItemCell0" forIndexPath:indexPath];
    cell.cellTextLabel.textColor = [JMHelpers jmTealColor];
    NSString *str;
    if (indexPath.row==2) {
        str = [JMHelpers displayNameForGameDifficulty:currentDifficulty];
    } else if (indexPath.row==3) {
        str = [JMHelpers displayNameForGameMode:currentGameMode];
    } else {
        str = title;
    }
    if (indexPath.row==1) {
        if ([title isEqualToString:@"start"]) {
            cell.cellTextLabel.textColor = [JMHelpers jmLightGreenColor];
        }
    }
    cell.cellTextLabel.text = str;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section==0) return 100.0f;
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row==0) { //game over
        RZViewAction *delay = [RZViewAction waitForDuration:0.25];
        [UIView rz_runAction:delay withCompletion:^(BOOL finished) {
            if (finished) {
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                RZViewAction *delay2 = [RZViewAction waitForDuration:0.25];
                [UIView rz_runAction:delay2 withCompletion:^(BOOL finished) {
                    if (finished) {
                        [JMGameManager sharedInstance].activeGameController.isGameOver = YES;
                        [self.revealViewController revealToggleAnimated:YES];
                        [[NSNotificationCenter defaultCenter] postNotificationName:[JMHelpers gameOverNotification] object:nil];
                    }
                }];
                
            }
        }];
        
    } else if (indexPath.row==1) { //restart/start
        [[JMGameManager sharedInstance] setCurrentDifficulty:currentDifficulty];
        [[JMGameManager sharedInstance] setCurrentGameMode:currentGameMode];
        RZViewAction *delay = [RZViewAction waitForDuration:0.25];
        [UIView rz_runAction:delay withCompletion:^(BOOL finished) {
            if (finished) {
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                RZViewAction *delay2 = [RZViewAction waitForDuration:0.25];
                [UIView rz_runAction:delay2 withCompletion:^(BOOL finished) {
                    if (finished) {
                        [[JMGameManager sharedInstance].activeGameController changeMode:[JMGameManager sharedInstance].currentGameMode];
                            [self.revealViewController revealToggleAnimated:YES];
                    }
                }];
            }
        }];
    } else if (indexPath.row==2) { //select dificulty
        if (currentDifficulty == kDifficultyInsane) {
            currentDifficulty = kDifficultyEasy;
        } else {
            currentDifficulty++;
        }
        if (currentDifficulty == [JMGameManager sharedInstance].currentDifficulty && currentGameMode == [JMGameManager sharedInstance].currentGameMode) {
            menuTitles = [normalMenuTitles copy];
        } else {
            menuTitles = [altMenuTitles copy];
        }
        [self.tableView reloadData];
        NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath2, indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    } else if (indexPath.row==3) { //select mode
        if (currentGameMode == kGameModeTimeAttack) {
            currentGameMode = kGameModeClassic;
        } else {
            currentGameMode++;
        }
        if (currentGameMode == [JMGameManager sharedInstance].currentGameMode && currentDifficulty == [JMGameManager sharedInstance].currentDifficulty) {
            menuTitles = [normalMenuTitles copy];
        } else {
            menuTitles = [altMenuTitles copy];
        }
        [self.tableView reloadData];
        NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath2, indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
@end
