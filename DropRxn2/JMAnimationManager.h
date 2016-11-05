//
//  JMAnimationManager.h
//  DropRXN2
//
//  Created by James Mundie on 10/26/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "JMHelpers.h"

typedef void (^completion)(BOOL finished);

@interface JMAnimationManager : NSObject

@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, assign) BOOL shouldEndNow;


+(instancetype)sharedInstance;


-(void)handleMatches;
-(void)doDrops;
-(void)addRow;
//-(void)removeAllColumns;
-(void)endGameWithCompletion:(completion)endGameCompletion;

@end
