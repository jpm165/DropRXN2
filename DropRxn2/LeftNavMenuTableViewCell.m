//
//  LeftNavMenuTableViewCell.m
//  DropRxn2
//
//  Created by James Mundie on 11/3/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "LeftNavMenuTableViewCell.h"
#import "JMHelpers.h"

@interface LeftNavMenuTableViewCell ()



@end

@implementation LeftNavMenuTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    //self.buttonImageView.layer.borderColor = [JMHelpers ghostWhiteColorWithAlpha:@1].CGColor;
    //self.buttonImageView.layer.borderWidth = 1.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
