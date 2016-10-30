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

@interface GameOverViewController ()

@property (nonatomic, strong) IBOutlet UIButton *btnNewGame;

@end

@implementation GameOverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:[JMHelpers gameOverNotification] object:nil];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.btnNewGame.layer.borderColor = [UIColor blackColor].CGColor;
    self.btnNewGame.layer.borderWidth = 2.0f;
    self.btnNewGame.layer.cornerRadius = 5.0f;
}

-(IBAction)startNewGame:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"mainVC"];
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)receivedNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:[JMHelpers gameOverNotification]]) {
        if (self.presentedViewController) [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
