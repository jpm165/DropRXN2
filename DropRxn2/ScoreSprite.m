//
//  ScoreSprite.m
//  DropRxn2
//
//  Created by James Mundie on 11/4/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "ScoreSprite.h"
#import "JMHelpers.h"

@interface ScoreSprite ()

{
    CGRect textRect;
    NSDictionary *textAttributes;
    NSString *text;
}

@property (nonatomic, strong) NSNumber *scoreNumber;

@end

@implementation ScoreSprite

-(id)initWithFrame:(CGRect)frame number:(NSNumber *)number {
    if (self = [super initWithFrame:frame]) {
        _scoreNumber = [self calculateNumberWithMultiplier:number];
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        text = @"+";
        text = [text stringByAppendingString:_scoreNumber.stringValue];
        textAttributes = [JMHelpers textAttributesWithGameFontSize:12.0 color:[JMHelpers jmTealColor]];
        textRect = [JMHelpers getRectForTextInBoundingBox:CGRectMake(0, 0, frame.size.width, frame.size.height) withText:text withAttributes:textAttributes];
        
    }
    return self;
}

-(NSNumber *)calculateNumberWithMultiplier:(NSNumber *)multiplier {
    /*
formula: for n chains, score = (7 + (n*7))* n) * (tier multiplier)
    = (7n +7)n * tm
    = 7n^2 +7n * tm
    -0: 7 x1
    -1: 14 x1
    -2: 42 x1
    -3: 84 x1
    -4: 140 * 2 = 280
    -5: 420 x2
    -6: 882 x3
    -7: 1176 x3
    -8: 1512 x3
    -9: 2520 x4
    -10: x4
    -11: x4
    -12: x4
    -13: x5 = 6370 (max)
     */
    long num = multiplier.longValue;
    if (num==13) return @(6370);
    if (num==0) return @(7);
    int tierMultiplier = 1;
    if (num >= 4) tierMultiplier++;
    if (num >= 6) tierMultiplier++;
    if (num >= 9) tierMultiplier++;
    NSNumber *score = @(((7*num*num)+(7*num))*tierMultiplier);
    //[[JMGameManager sharedInstance] setCurrentScore:score];
    //NSLog(@"after score updated");
    //dispatch_async(dispatch_get_main_queue(), ^{
        //[[NSNotificationCenter defaultCenter] postNotificationName:[JMHelpers currentScoreUpdateNotification] object:nil];
    //});
    return score;
}

- (void)drawRect:(CGRect)rect {
    //[[UIColor blackColor] setStroke];
    //UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    //path.lineWidth = 2.0;
    //[path stroke];
    [text drawInRect:textRect withAttributes:textAttributes];
}


@end
