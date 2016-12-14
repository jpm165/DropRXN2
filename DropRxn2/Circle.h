//
//  Circle.h
//  DropRxn
//
//  Created by James Mundie on 10/21/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "JMHelpers.h"

@class RZViewAction;

@interface Circle : UIView

@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, strong) NSNumber *initialSlot;
@property (nonatomic, assign) BOOL shouldRemove;
@property (nonatomic, strong) NSNumber *columnNumber;
@property (nonatomic, strong) NSNumber *changeToNumber;

-(instancetype)initWithFrame:(CGRect)frame borderWidth:(CGFloat)borderWidth;
-(void)setFillColor:(UIColor *)color;
-(RZViewAction *)changeNumber:(NSNumber *)number;

@end
