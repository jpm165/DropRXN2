//
//  JMPersistenceManager.h
//  DropRxn2
//
//  Created by James Mundie on 12/14/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JMPersistenceManager : NSObject

+(instancetype)sharedInstance;
-(void)saveState;
-(NSDictionary *)getState;
-(NSNumber *)getHighScoreForDifficultyLevel:(NSString *)level;
-(NSNumber *)getMostChainsForDifficultyLevel:(NSString *)level;
-(void)resetState;

@end
