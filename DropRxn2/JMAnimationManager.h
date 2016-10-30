//
//  JMAnimationManager.h
//  DropRXN2
//
//  Created by James Mundie on 10/26/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "JMHelpers.h"

@class RZViewAction;
@class Column;
@class DropCounter;

@interface JMAnimationManager : NSObject

@property (nonatomic, strong) NSArray *columns;
@property (nonatomic, strong) DropCounter *dropCounter;

+(instancetype)sharedInstance;

-(void)addColumn:(Column *)column;
-(void)handleMatches;
-(void)doDrops;
-(void)addRow;
-(void)removeAllColumns;
//-(void)doDrops:(BOOL)handleMatchesAnyway shouldDecrement:(BOOL)shouldDecrement;

@end
