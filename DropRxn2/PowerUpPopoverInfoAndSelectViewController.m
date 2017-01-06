//
//  PowerUpPopoverInfoAndSelectViewController.m
//  DropRxn2
//
//  Created by James Mundie on 12/20/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "PowerUpPopoverInfoAndSelectViewController.h"
#import "JMHelpers.h"

static NSString *const selectLabelSelectText = @"(tap to select)";
static NSString *const selectLabelDeSelectText = @"(tap to deselect)";

@interface PowerUpPopoverInfoAndSelectViewController ()

@property (nonatomic, strong) IBOutlet UIButton *powerUpInfoLabel;
@property (nonatomic, strong) IBOutlet UIImageView *powerUpSymbol;
@property (nonatomic, strong) IBOutlet UILabel *selectLabel;
@property (nonatomic, assign) CGSize textSize;
@property (nonatomic, strong) NSDictionary *textAttributes;
@property (nonatomic, strong) UIFont *font;

@end

@implementation PowerUpPopoverInfoAndSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [JMHelpers ghostWhiteColorWithAlpha:@1];
    [self.powerUpInfoLabel setTitle:self.powerUp.description forState:UIControlStateNormal];
    [self.powerUpInfoLabel setTitleColor:[JMHelpers jmTealColor] forState:UIControlStateNormal];
    self.powerUpInfoLabel.layer.borderColor = [UIColor blackColor].CGColor;
    self.powerUpInfoLabel.layer.borderWidth = 2.0;
    self.powerUpInfoLabel.layer.cornerRadius = 5.0;
    self.powerUpInfoLabel.titleLabel.numberOfLines = 0;
    [self.powerUpInfoLabel addTarget:self action:@selector(choosePowerUp) forControlEvents:UIControlEventTouchUpInside];
    
    self.powerUpSymbol.image = [UIImage imageNamed:self.powerUp.symbol];
    
    //[self.powerUpInfoLabel sizeToFit];
    self.preferredContentSize = CGSizeMake(375, 110);
    self.view.backgroundColor = [UIColor clearColor];
    
}

-(void)choosePowerUp {
    //TODO do something with powerup ball when selected
    // add selected state for powerup balls
    // change tap to select to tap to de-select when ball state is selected
    //remove powerup selector when 3 powerups selected
    // colors for power up balls?
    //
    [[JMGameManager sharedInstance] addPowerUp:self.powerUp];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self.view addSubview:self.powerUpInfoLabel];
    if (self.powerUp.wasSelected) {
        self.selectLabel.text = selectLabelDeSelectText;
    } else {
       self.selectLabel.text = selectLabelSelectText; 
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
