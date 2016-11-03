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
}

@end

@implementation DropCounter

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        if ([JMGameManager sharedInstance].demoModeEnabled) {
            _currentDrop = 1;
        } else {
            _currentDrop = [JMHelpers numDrops];
        }
        [self addDropsForRadius:frame.size.height];
    }
    return self;
}

-(void)resetDrops {
    _currentDrop = [JMHelpers numDrops];
    [self setNeedsDisplay];
}

-(void)decrementCurrentDrop {
    if (_currentDrop==0) {
        if ([JMGameManager sharedInstance].demoModeEnabled) {
            _currentDrop = 0;
        } else {
            _currentDrop = [JMHelpers numDrops];
        }
        [self setNeedsDisplay];
        return;
    }
    _currentDrop--;
    [self setNeedsDisplay];
}

-(void)addDropsForRadius:(CGFloat)size {
    NSMutableArray *array = [NSMutableArray array];
    for (int drop=0; drop<_currentDrop; drop++) {
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake((drop*size)+(drop*2), 0, size, size)];
        [array addObject:path];
        
    }
    drops = array;
}

- (void)drawRect:(CGRect)rect {
    for (int drop=0; drop<drops.count; drop++) {
        UIBezierPath *path = drops[drop];
        [[UIColor lightGrayColor] setFill];
        if (drop==_currentDrop-1) [[UIColor blackColor] setFill];
        [path fill];
    }
}

@end
