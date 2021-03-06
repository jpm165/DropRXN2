//
//  JMHelpers.h
//  DropRxn
//
//  Created by James Mundie on 10/24/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//
#import <Foundation/Foundation.h>

typedef enum {
    kGameModeClassic,
    kGameModePower,
    kGameModeTimeAttack
} GameMode;

typedef enum {
    kDifficultyEasy,
    kDifficultyLessEasy,
    kDifficultyHarder,
    kDifficultyMoreHarder,
    kDifficultyInsane
} GameDifficulty;

typedef enum {
    kPowerUpTypeRemoveAllNext,
    kPowerUpTypeDecrementAllGreys,
    kPowerUpTypeDecrementNumbered,
    kPowerUpTypeIncrementNumbered,
    kPowerUpTypePointsBonus,
    kPowerUpTypeExpBonus
} PowerUpType;

typedef void (^completion)(BOOL finished);

#import <UIKit/UIKit.h>
#import "Circle.h"
#import "Column.h"
#import "JMAnimationManager.h"
#import "DropCounter.h"
#import "JMGameManager.h"

@interface JMHelpers : NSObject


+(UIColor *)jmOrangeColor;
+(UIColor *)jmDarkBlueColor;
+(UIColor *)jmDarkRedColor;
+(UIColor *)jmDarkOrangeColor;
+(UIColor *)jmDarkGreenColor;
+(UIColor *)jmDarkGrayColor;
+(UIColor *)jmPurpleColor;

+(UIColor *)jmLightBlueColor;
+(UIColor *)jmLightGreenColor;
+(UIColor *)jmLightGrayColor;

+(UIColor *)jmLightGreenColorWithAlpha:(NSNumber *)alpha;

+(UIColor *)jmRedColor;
+(UIColor *)jmTealColor;

+(UIColor *)ghostWhiteColorWithAlpha:(NSNumber *)alpha;

+(UIColor *)randomColor;
+(int)random;
+(int)randomBasedOnRowCount:(int)rowCount;
+(int)randomNonGrey;
+(NSArray *)allColors;

+(CGSize)sizeForText:(NSString *)text inBoundingBox:(CGRect)boundingBox withAttributes:(NSDictionary *)attributes;
+(NSDictionary *)textAttributesWithGameFontSize:(CGFloat)fontSize color:(UIColor *)fontColor;
+(NSDictionary *)textAttributesWithFontSize:(CGFloat)fontSize;
+(CGRect)getRectForTextInBoundingBox:(CGRect)boundingBox withText:(NSString *)text withAttributes:(NSDictionary *)attributes;

+(NSNumber *)numballs;
+(NSNumber *)numColumns;
+(CGFloat)circleRadius;
+(CGFloat)columnHeight;
+(CGFloat)columnsWidth;
+(CGRect)calculateColumnFrameAtPoint:(CGPoint)beginPoint offset:(int)offset;
+(CGFloat)borderWidth;
+(NSInteger)numDrops;

+(NSString *)gameOverNotification;
+(NSString *)toggleUserInputPauseNotification;
+(NSString *)gameRestartNotification;
+(NSString *)gameResetNotificationName;
+(NSString *)currentScoreUpdateNotification;

+(NSNumber *)defaultDifficulty;

+(NSString *)displayNameForGameMode:(GameMode)gameMode;
+(GameMode)gameModeForDisplayName:(NSString *)displayName;
+(NSArray *)gameModes;

+(NSString *)displayNameForGameDifficulty:(GameDifficulty)gameDifficulty;
+(GameDifficulty)gameDifficultyForDisplayName:(NSString *)displayName;
+(NSArray *)gameDifficulties;

@end
