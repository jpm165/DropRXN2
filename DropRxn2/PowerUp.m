//
//  PowerUp.m
//  DropRxn2
//
//  Created by James Mundie on 12/20/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "PowerUp.h"
#import "Circle.h"
#import "JMGameManager.h"

@interface PowerUp ()

{
    UIColor *originalFillColor;
    BOOL isPresentingPopover;
}



@end

@implementation PowerUp

-(void)setType:(PowerUpType)type {
    self.userInteractionEnabled = YES;
    isPresentingPopover = NO;
    originalFillColor = self.fillColor;
    _type = type;
    switch (type) {
        case kPowerUpTypeRemoveAllNext:
            _symbol = @"X!";
            break;
        case kPowerUpTypeDecrementAllGreys:
            _symbol = @"V-";
            break;
        default:
            break;
    }
    if (_symbol) [self originalAttributes];
}

-(void)originalAttributes {
    textAttributes = [JMHelpers textAttributesWithGameFontSize:24 color:[UIColor whiteColor]];
    numberRect = [JMHelpers getRectForTextInBoundingBox:self.bounds withText:_symbol withAttributes:textAttributes];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (self.symbol) [self.symbol drawInRect:numberRect withAttributes:textAttributes];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!isPresentingPopover) {
        textAttributes = [JMHelpers textAttributesWithGameFontSize:28 color:[UIColor whiteColor]];
        numberRect = [JMHelpers getRectForTextInBoundingBox:self.bounds withText:_symbol withAttributes:textAttributes];
        self.fillColor = [JMHelpers jmRedColor];
        isPresentingPopover = YES;
        [self.delegate isSelected:self];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self originalAttributes];
            self.fillColor = originalFillColor;
            isPresentingPopover = NO;
            [self setNeedsDisplay];
        });
    }
    
    [self setNeedsDisplay];
    
}



/*
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
 
}
 */

-(NSString *)description {
    NSString *retval;
    switch (self.type) {
        case kPowerUpTypeRemoveAllNext:
            retval = @"Remove all balls matching the 'next' ball.";
            break;
        case kPowerUpTypeDecrementAllGreys:
            retval = @"Decrement all grey balls.";
        default:
            retval = @"No description.";
            break;
    }
    return retval;
}

@end
