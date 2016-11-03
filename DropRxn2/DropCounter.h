//
//  DropCounter.h
//  DropRXN2
//
//  Created by James Mundie on 10/28/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "JMHelpers.h"

@interface DropCounter : UIView

@property (nonatomic, assign) NSInteger currentDrop;

-(void)decrementCurrentDrop;
-(void)resetDrops;

@end
