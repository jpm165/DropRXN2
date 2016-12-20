//
//  PowerUpPopoverInfoAndSelectViewController.m
//  DropRxn2
//
//  Created by James Mundie on 12/20/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "PowerUpPopoverInfoAndSelectViewController.h"
#import "JMHelpers.h"

@interface PowerUpPopoverInfoAndSelectViewController ()

@property (nonatomic, strong) IBOutlet UIButton *powerUpInfoLabel;
@property (nonatomic, strong) IBOutlet UILabel *powerUpSymbol;
@property (nonatomic, assign) CGSize textSize;
@property (nonatomic, strong) NSDictionary *textAttributes;
@property (nonatomic, strong) UIFont *font;

@end

@implementation PowerUpPopoverInfoAndSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [JMHelpers ghostWhiteColorWithAlpha:@1];
    //self.powerUpInfoLabel = [[UILabel alloc] init];
    //self.powerUpInfoLabel.textAlignment = NSTextAlignmentCenter;
    //self.font = [UIFont fontWithName:@"RepublikaII" size:20];
    //self.textAttributes = @{NSFontAttributeName:_font};
    //self.textSize = [self.powerUp.description sizeWithAttributes:self.textAttributes];
    //CGRect boundingRect = [self.powerUp.description boundingRectWithSize:CGSizeMake(self.textSize.width, 500) options:NSStringDrawingUsesLineFragmentOrigin attributes:self.textAttributes context:nil];
    
    //self.powerUpInfoLabel.font = _font;
    //self.powerUpInfoLabel.numberOfLines = 0;
    [self.powerUpInfoLabel setTitle:self.powerUp.description forState:UIControlStateNormal];
    [self.powerUpInfoLabel setTitleColor:[JMHelpers jmRedColor] forState:UIControlStateNormal];
    self.powerUpInfoLabel.layer.borderColor = [JMHelpers ghostWhiteColorWithAlpha:@1].CGColor;
    self.powerUpInfoLabel.layer.borderWidth = 1.0;
    self.powerUpInfoLabel.layer.cornerRadius = 5.0;
    self.powerUpInfoLabel.titleLabel.numberOfLines = 0;
    [self.powerUpInfoLabel addTarget:self action:@selector(choosePowerUp) forControlEvents:UIControlEventTouchUpInside];
    
    self.powerUpSymbol.textColor = [UIColor blackColor];
    self.powerUpSymbol.text = self.powerUp.symbol;
    self.powerUpSymbol.layer.borderColor = [JMHelpers jmTealColor].CGColor;
    self.powerUpSymbol.layer.borderWidth = 2.0;
    self.powerUpSymbol.layer.cornerRadius = 5;
    
    //[self.powerUpInfoLabel sizeToFit];
    self.preferredContentSize = CGSizeMake(375, 100);
    self.view.backgroundColor = [UIColor clearColor];
    
}

-(void)choosePowerUp {
    [[JMGameManager sharedInstance] addPowerUp:self.powerUp];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self.view addSubview:self.powerUpInfoLabel];
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
