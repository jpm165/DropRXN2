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
    NSNumber *decMod;
    NSNumber *level;
}

@end

@implementation DropCounter

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        decMod = @0;
        if ([JMGameManager sharedInstance].demoModeEnabled) {
            _currentDrop = 1;
        } else {
            _currentDrop = [self totalDrops].integerValue;
        }
        level = @1;
        [self addDropsForRadius:frame.size.height];
    }
    return self;
}

-(void)resetDrops {
    if ([JMGameManager sharedInstance].demoModeEnabled) {
        _currentDrop = 0;
    } else {
        _currentDrop = [self totalDrops].integerValue;
    }
    [self setNeedsDisplay];
}

-(NSNumber *)totalDrops {
    NSNumber *numDrops = @([JMHelpers numDrops]);
    int difficultyModifiedNumdrops = numDrops.intValue - (5*[JMGameManager sharedInstance].difficultyLevel.intValue);
    int currentTotalDrops = difficultyModifiedNumdrops - decMod.intValue;
    return @(currentTotalDrops);
}

-(void)removeADrop {
    if ([self totalDrops].intValue - 1 >= 5) {
        decMod = @(decMod.intValue+1);
        NSMutableArray *array = [drops mutableCopy];
        [array removeLastObject];
        drops = array;
        [self setNeedsDisplay];
    }
}

-(void)decrementCurrentDrop {
    if (_currentDrop==0) {
        level = @(level.intValue+1);
        [[JMGameManager sharedInstance] updateLevel:level];
        [self removeADrop];
        [self resetDrops];
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
