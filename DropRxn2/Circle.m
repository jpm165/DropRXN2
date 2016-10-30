//
//  Circle.m
//  DropRxn
//
//  Created by James Mundie on 10/21/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "Circle.h"

@interface Circle ()

{
    UIBezierPath *circlePath;
    CGFloat lineWidth;
    UIColor *defaultFillColor;
    CGRect numberRect;
    NSDictionary *textAttributes;
}

@property (nonatomic, strong) UIColor *fillColor;

@end

@implementation Circle

-(instancetype)initWithFrame:(CGRect)frame borderWidth:(CGFloat)borderWidth {
    if (self = [super initWithFrame:frame]) {
        CGFloat sizeWithBorder = frame.size.width - (borderWidth);
        CGRect frameWithBorder = CGRectMake(borderWidth/2, borderWidth/2, sizeWithBorder, sizeWithBorder);
        circlePath = [UIBezierPath bezierPathWithOvalInRect:frameWithBorder];
        lineWidth = borderWidth;
        circlePath.lineWidth = borderWidth;
        self.backgroundColor = [UIColor clearColor];
        defaultFillColor = [UIColor redColor];
        self.fillColor = defaultFillColor;
        textAttributes = [JMHelpers textAttributesWithFontSize:24];
    }
    return self;
}

-(void)setNumber:(NSNumber *)number {
    _number = number;
    numberRect = [JMHelpers getRectForTextInBoundingBox:self.bounds withText:number.stringValue withAttributes:[JMHelpers textAttributesWithFontSize:24]];
    NSArray *colors = [JMHelpers allColors];
    _fillColor = (number.integerValue<colors.count) ? colors[number.integerValue] : colors[0];
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
    [self.number.stringValue drawInRect:numberRect withAttributes:textAttributes];
}


@end
