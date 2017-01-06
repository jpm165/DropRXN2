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
    UIImageView *imageView;
    BOOL wasSelected;
    UIBezierPath *circlePath;
}



@end

@implementation PowerUp

-(void)setType:(PowerUpType)type {
    self.userInteractionEnabled = YES;
    _isPresentingPopover = NO;
    originalFillColor = self.fillColor;
    _type = type;
    if (!imageView) imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    if (![self.subviews containsObject:imageView]) [self addSubview:imageView];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    switch (type) {
        case kPowerUpTypeRemoveAllNext:
            _symbol = @"powerUpLightningBolt_soft";
            break;
        case kPowerUpTypeDecrementAllGreys:
            _symbol = @"powerUpDecGray";
            break;
        case kPowerUpTypeDecrementNumbered:
            _symbol = @"powerUpDecNumbered";
            break;
        case kPowerUpTypeIncrementNumbered:
            _symbol = @"powerUpIncNumbered";
            break;
        case kPowerUpTypePointsBonus:
            _symbol = @"powerUpPoints";
            break;
        case kPowerUpTypeExpBonus:
            _symbol = @"powerUpExp";
            break;
        default:
            break;
    }
    if (_symbol) imageView.image = [UIImage imageNamed:_symbol];
}

-(void)originalAttributes {
    textAttributes = [JMHelpers textAttributesWithGameFontSize:24 color:[UIColor whiteColor]];
    numberRect = [JMHelpers getRectForTextInBoundingBox:self.bounds withText:_symbol withAttributes:textAttributes];
}

-(void)selectMe {
    [imageView removeFromSuperview];
    circlePath = [UIBezierPath bezierPathWithOvalInRect:imageView.frame];
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = circlePath.bounds;
    layer.path = [circlePath CGPath];
    layer.backgroundColor = [UIColor clearColor].CGColor;
    layer.fillColor = [JMHelpers jmLightGreenColorWithAlpha:@(0.5)].CGColor;
    layer.strokeColor = [UIColor greenColor].CGColor;
    imageView.layer.mask = layer;
    [self addSubview:imageView];
    self.wasSelected = YES;
}

-(void)deSelectMe {
    [imageView removeFromSuperview];
    imageView = nil;
    imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.image = [UIImage imageNamed:_symbol];
    [self addSubview:imageView];
    self.wasSelected = NO;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*
- (void)drawRect:(CGRect)rect {
    //[[UIColor clearColor] setFill];
    //[circlePath fill];
    if (wasSelected) {
        //[[UIColor blackColor] setFill];
        [[JMHelpers jmLightGreenColorWithAlpha:@(0.5)] setFill];
        [[UIColor greenColor] setStroke];
        [circlePath stroke];
        [circlePath fill];
    }
    
    
}
*/

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_isPresentingPopover) {
        //textAttributes = [JMHelpers textAttributesWithGameFontSize:28 color:[UIColor whiteColor]];
        //numberRect = [JMHelpers getRectForTextInBoundingBox:self.bounds withText:_symbol withAttributes:textAttributes];
        //self.fillColor = [JMHelpers jmRedColor];
        _isPresentingPopover = YES;
        if ([JMGameManager sharedInstance].activeGameController.isPresentingPopover) {
            [self.delegate isDelselected:self];
        } else {
            [self.delegate isSelected:self];
        }
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //[self originalAttributes];
            //self.fillColor = originalFillColor;
            _isPresentingPopover = NO;
            [self.delegate isDelselected:nil];
            //[self setNeedsDisplay];
        });
    }
    
    //[self setNeedsDisplay];
    
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
            retval = @"Dark grays become light, light become numbered.";
            break;
        case kPowerUpTypeDecrementNumbered:
            retval = @"Decrement all numbered balls.";
            break;
        case kPowerUpTypeIncrementNumbered:
            retval = @"Increment all numbered balls.";
            break;
        case kPowerUpTypePointsBonus:
            retval = @"Temporarily grants a 25% bonus on points scored.";
            break;
        case kPowerUpTypeExpBonus:
            retval = @"Temporarily increases exp points earned.";
            break;
        default:
            retval = @"No description.";
            break;
    }
    return retval;
}

@end
