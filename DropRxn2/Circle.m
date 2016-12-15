//
//  Circle.m
//  DropRxn
//
//  Created by James Mundie on 10/21/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "Circle.h"
#import "UIView+RZViewActions.h"
#import "JMHelpers.h"

@interface Circle ()

{
    UIBezierPath *circlePath;
    CGFloat lineWidth;
    UIColor *defaultFillColor;
    CGRect numberRect;
    NSDictionary *textAttributes;
    BOOL shouldDrawNumber;
}

@property (nonatomic, strong) UIColor *fillColor;

@end

@implementation Circle

-(instancetype)initWithFrame:(CGRect)frame borderWidth:(CGFloat)borderWidth {
    if (self = [super initWithFrame:frame]) {
        CGFloat sizeWithBorder = frame.size.width - (borderWidth);
        CGRect frameWithBorder = CGRectMake(borderWidth/2, borderWidth/2, sizeWithBorder-(borderWidth/2), sizeWithBorder-(borderWidth/2));
        circlePath = [UIBezierPath bezierPathWithOvalInRect:frameWithBorder];
        lineWidth = borderWidth;
        circlePath.lineWidth = borderWidth;
        self.backgroundColor = [UIColor clearColor];
        defaultFillColor = [UIColor redColor];
        self.fillColor = defaultFillColor;
        textAttributes = [JMHelpers textAttributesWithFontSize:24];
        self.userInteractionEnabled = NO;
        [self setTranslatesAutoresizingMaskIntoConstraints:YES];
        shouldDrawNumber = YES;
    }
    return self;
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    CGFloat borderWidth = [JMHelpers borderWidth];
    CGFloat sizeWithBorder = frame.size.width - (borderWidth);
    CGRect frameWithBorder = CGRectMake(borderWidth/2, borderWidth/2, sizeWithBorder-(borderWidth/2), sizeWithBorder-(borderWidth/2));
    circlePath = [UIBezierPath bezierPathWithOvalInRect:frameWithBorder];
    lineWidth = borderWidth;
    circlePath.lineWidth = borderWidth;
}

-(RZViewAction *)changeNumber:(NSNumber *)number {
    CGRect oldframe = self.frame;
    RZViewAction *pulseUp = [RZViewAction action:^{
        CGRect newFramePulseBig = CGRectMake(CGRectGetMinX(self.frame)-2.5, CGRectGetMinY(self.frame)-2.5, CGRectGetWidth(self.frame)+5, CGRectGetHeight(self.frame)+5);
        
        self.frame = newFramePulseBig;
    } withDuration:0.1];
    RZViewAction *pulseDown = [RZViewAction action:^{
        self.frame = oldframe;
    } withDuration:0.1];
    
    
    return [RZViewAction sequence:@[pulseUp, pulseDown]];
    
    
//    [UIView rz_runAction:[RZViewAction sequence:@[pulseUp, pulseDown]] withCompletion:^(BOOL finished) {
//        if (finished) {
//            [self setNumber:number];
//        }
//    }];
}

-(void)setNumber:(NSNumber *)number {
    _number = number;
    numberRect = [JMHelpers getRectForTextInBoundingBox:self.bounds withText:number.stringValue withAttributes:[JMHelpers textAttributesWithFontSize:24]];
    NSArray *colors = [JMHelpers allColors];
    
    _fillColor = (number.integerValue<colors.count) ? colors[number.integerValue] : colors[0];
    if (number.intValue > [JMHelpers numballs].intValue) {
        shouldDrawNumber = NO;
    } else {
        shouldDrawNumber = YES;
    }
    [self setNeedsDisplay];
}

-(void)setFillColor:(UIColor *)color {
    _fillColor = (color==nil) ? defaultFillColor : color;
}

- (void)drawRect:(CGRect)rect {
    [[UIColor blackColor] setStroke];
    [circlePath stroke];
    [self.fillColor setFill];
    [circlePath fill];
    
    //draw the number
    if (shouldDrawNumber) [self.number.stringValue drawInRect:numberRect withAttributes:textAttributes];
}


@end
