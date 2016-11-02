//
//  DropCounter.m
//  DropRXN2
//
//  Created by James Mundie on 10/28/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "DropCounter.h"

@interface DropCounter ()

{
    NSArray *drops;
    NSInteger currentDrop;
}

@end

@implementation DropCounter

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        if ([JMAnimationManager sharedInstance].demoModeEnabled) {
            currentDrop = 1;
        } else {
            currentDrop = [JMHelpers numDrops];
        }
        [self addDropsForRadius:frame.size.height];
    }
    return self;
}

-(NSInteger)decrementCurrentDrop {
    if (currentDrop==1) {
        if ([JMAnimationManager sharedInstance].demoModeEnabled) {
            currentDrop = 1;
        } else {
            currentDrop = [JMHelpers numDrops];
        }
        [self setNeedsDisplay];
        return currentDrop;
    }
    currentDrop--;
    [self setNeedsDisplay];
    return currentDrop;
}

-(void)addDropsForRadius:(CGFloat)size {
    NSMutableArray *array = [NSMutableArray array];
    for (int drop=0; drop<currentDrop; drop++) {
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake((drop*size)+(drop*2), 0, size, size)];
        [array addObject:path];
        
    }
    drops = array;
}

- (void)drawRect:(CGRect)rect {
    for (int drop=0; drop<drops.count; drop++) {
        UIBezierPath *path = drops[drop];
        [[UIColor lightGrayColor] setFill];
        if (drop==currentDrop-1) [[UIColor blackColor] setFill];
        [path fill];
    }
}

@end
