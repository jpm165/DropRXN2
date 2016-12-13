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

@interface LeftNavMenuTableViewController ()

{
    NSArray *menuItems, *menuTitles, *difficulties;
}

@property (nonatomic, strong) IBOutlet UIImageView *quitGameBtnImageView;

@end

@implementation LeftNavMenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //menuItems = @[@"menuItemCell0", @"menuItemCell1"];
    menuTitles = @[@"quit game", @"restart", @"difficulty"];
    difficulties = @[@"easy", @"less easy", @"harder", @"more harder", @"insane"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LeftNavMenuTableViewCell *cell;
    NSString *title = menuTitles[indexPath.row];
    cell = (LeftNavMenuTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"menuItemCell0" forIndexPath:indexPath];
    cell.cellTextLabel.textColor = [JMHelpers jmTealColor];
    NSString *str;
    if (indexPath.row==2) {
        NSNumber *num = [[JMGameManager sharedInstance] getDifficultyLevel];
        str = [NSString stringWithFormat:@"%@", difficulties[num.intValue]];
        [cell.cellTextLabel setAdjustsFontSizeToFitWidth:YES];
    } else {
        str = title;
    }
    cell.cellTextLabel.text = str;
    // Configure the cell...
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section==0) return 100.0f;
    return 0;
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(nonnull UIView *)view forSection:(NSInteger)section {
    if (section==0) [view setTintColor:[UIColor clearColor]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row==0) {
        RZViewAction *delay = [RZViewAction waitForDuration:0.25];
        [UIView rz_runAction:delay withCompletion:^(BOOL finished) {
            if (finished) {
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                RZViewAction *delay2 = [RZViewAction waitForDuration:0.25];
                [UIView rz_runAction:delay2 withCompletion:^(BOOL finished) {
                    if (finished) {
                        [self.revealViewController revealToggleAnimated:YES];
                        [[NSNotificationCenter defaultCenter] postNotificationName:[JMHelpers gameOverNotification] object:nil];
                    }
                }];
                
            }
        }];
        
    } else if (indexPath.row==1) {
        RZViewAction *delay = [RZViewAction waitForDuration:0.25];
        [UIView rz_runAction:delay withCompletion:^(BOOL finished) {
            if (finished) {
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                RZViewAction *delay2 = [RZViewAction waitForDuration:0.25];
                [UIView rz_runAction:delay2 withCompletion:^(BOOL finished) {
                    if (finished) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:[JMHelpers gameRestartNotification] object:nil];
                            [self.revealViewController revealToggleAnimated:YES];
                    }
                }];
            }
        }];
    } else if (indexPath.row==2) {
        NSNumber *num = [JMGameManager sharedInstance].difficultyLevel;
        if (num.intValue >= 4) {
            num = @0;
        } else {
            num = @(num.intValue + 1);
        }
        [[JMGameManager sharedInstance] setDifficultyLevel:num];
        [self.tableView reloadData];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
