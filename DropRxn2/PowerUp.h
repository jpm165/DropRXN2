//
//  PowerUp.h
//  DropRxn2
//
//  Created by James Mundie on 12/20/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

@class Circle;
#import "JMHelpers.h"

@protocol PowerUpInfoAndSelectProtocol

-(void)isSelected:(id)sender;
-(void)isDelselected:(id)sender;

@end

@interface PowerUp : Circle

@property (nonatomic, assign) PowerUpType type;
@property (nonatomic, assign) id<PowerUpInfoAndSelectProtocol>delegate;
@property (nonatomic, strong) NSString *symbol;

@end
