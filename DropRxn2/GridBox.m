//
//  GridBox.m
//  DropRxn2
//
//  Created by James Mundie on 11/1/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "GridBox.h"
#import "JMHelpers.h"
#import "UIView+RZViewActions.h"

@implementation GridBox

-(id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.borderColor = [JMHelpers ghostWhiteColorWithAlpha:@1].CGColor;
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderWidth = 1.0;
        self.userInteractionEnabled = NO;
    }
    return self;
}

-(RZViewAction *)flashOnBG {
    RZViewAction *colorFlash = [RZViewAction action:^{
        self.backgroundColor = [JMHelpers ghostWhiteColorWithAlpha:@1];
    } withDuration:0.2];
    return colorFlash;
}

-(RZViewAction *)flashOffBG {
    RZViewAction *returnColor = [RZViewAction action:^{
        self.backgroundColor = [UIColor clearColor];
    } withDuration:0.3];
    return returnColor;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
