//
//  JMHelpers.m
//  DropRxn
//
//  Created by James Mundie on 10/24/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import "JMHelpers.h"

#define RGBAUICOLOR(r, g, b, a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define NUMBALLS 7
#define NUMCOLS 7
#define CIRCLE_RADIUS 50.0f
#define BORDER_WIDTH 3.0f
#define FULL_DROP_COUNTER 25
#define DEFAULTDIFFICULTY 0

static NSString *const gameOverNotificationName = @"gameOverNotif";
static NSString *const toggleUserInputPauseNotificationName = @"toggleUserInputPauseNotif";
static NSString *const gameRestartNotificationName = @"gameRestartNotif";
static NSString *const gameResetNotificationName = @"gameResetNotif";
static NSString *const currentScoreUpdated = @"currentScoreUpdatedNotif";

@implementation JMHelpers

+(UIColor *)jmDarkBlueColor {
    return RGBAUICOLOR(0, 10, 100, 1);
}

+(UIColor *)jmDarkRedColor {
    return RGBAUICOLOR(140, 18, 46, 1);
}

+(UIColor *)jmDarkOrangeColor {
    return RGBAUICOLOR(200, 98, 0, 1);
}

+(UIColor *)jmDarkGreenColor {
    return RGBAUICOLOR(82, 92, 61, 1);
}

+(UIColor *)jmDarkGrayColor {
    return RGBAUICOLOR(99, 99, 99, 1);
}

+(UIColor *)jmPurpleColor {
    return RGBAUICOLOR(154, 64, 1, 1);
}

+(UIColor *)jmLightBlueColor {
    return RGBAUICOLOR(42, 81, 176, 1);
}

+(UIColor *)jmLightGreenColor {
    return RGBAUICOLOR(151, 168, 111, 1);
}

+(UIColor *)jmLightGrayColor {
    return RGBAUICOLOR(156, 156, 156, 1);
}

+(UIColor *)ghostWhiteColorWithAlpha:(NSNumber *)alpha {
    CGFloat a = (alpha==nil) ? 1 : alpha.floatValue;
    return RGBAUICOLOR(235, 235, 235, a);
}

+(UIColor *)jmRedColor {
    return RGBAUICOLOR(220, 0, 0, 1);
}

+(UIColor *)jmTealColor {
    return RGBAUICOLOR(0, 152, 206, 1);
}

+(UIColor *)randomColor {
    NSArray *array = [JMHelpers allColors];
    int random = arc4random_uniform((int)array.count);
    return array[random];
}

+(int)random {
    NSArray *array = [JMHelpers allColors];
    return arc4random_uniform((int)array.count-1)+1;
}

+(int)randomBasedOnRowCount:(int)rowCount {
    NSArray *array = [JMHelpers allColors];
    int quarter = arc4random_uniform(4)+1;
    if (quarter == 3) {
        return 9;
    }
    int half = [JMHelpers numballs].intValue/2;
    if (rowCount>half) {
        int coinFlip = arc4random_uniform(2)+1;
        if (coinFlip>1) {
            int random = arc4random_uniform((int)array.count-5)+1;
            return random;
        }
    }
    int random = arc4random_uniform((int)array.count-1)+1;
    return random;
}

+(int)randomNonGrey {
    NSArray *array = [JMHelpers allColors];
    return arc4random_uniform((int)array.count-3)+1;
}

+(NSArray *)allColors {
    return @[[UIColor blackColor],
             [JMHelpers jmDarkBlueColor],
             [JMHelpers jmDarkRedColor],
             [JMHelpers jmDarkOrangeColor],
             [JMHelpers jmLightBlueColor],
             [JMHelpers jmDarkGreenColor],
             [JMHelpers jmLightGreenColor],
             [JMHelpers jmPurpleColor],
             [JMHelpers jmLightGrayColor],
             [JMHelpers jmDarkGrayColor]];
}

+(CGSize)sizeForText:(NSString *)text inBoundingBox:(CGRect)boundingBox withAttributes:(NSDictionary *)attributes {
    CGRect textSizeRect = [text boundingRectWithSize:CGSizeMake(CGRectGetWidth(boundingBox), 200) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    return textSizeRect.size;
}

+(NSDictionary *)textAttributesWithGameFontSize:(CGFloat)fontSize color:(UIColor *)fontColor {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    return @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize],
             NSParagraphStyleAttributeName: paragraphStyle,
             NSForegroundColorAttributeName: fontColor};
}

+(NSDictionary *)textAttributesWithFontSize:(CGFloat)fontSize {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    return @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize],
             NSParagraphStyleAttributeName: paragraphStyle,
             NSForegroundColorAttributeName: [UIColor whiteColor]};
}

+(CGRect)getRectForTextInBoundingBox:(CGRect)boundingBox withText:(NSString *)text withAttributes:(NSDictionary *)attributes {
    CGSize textSize = [JMHelpers sizeForText:text inBoundingBox:boundingBox withAttributes:attributes];
    return CGRectMake(CGRectGetMidX(boundingBox)-textSize.width/2, CGRectGetMidY(boundingBox)-textSize.height/2, textSize.width, textSize.height);
}

+(NSNumber *)numballs {
    return @(NUMBALLS);
}

+(NSNumber *)numColumns {
    return @(NUMCOLS);
}

+(CGFloat)circleRadius {
    return CIRCLE_RADIUS;
}

+(CGFloat)columnHeight {
    return [JMHelpers numballs].floatValue*[JMHelpers circleRadius];
}

+(CGFloat)columnsWidth {
    return [JMHelpers numColumns].floatValue*[JMHelpers circleRadius];
}

+(CGRect)calculateColumnFrameAtPoint:(CGPoint)beginPoint offset:(int)offset {
    return CGRectMake(beginPoint.x+(offset*[JMHelpers circleRadius]),
                      beginPoint.y,
                      [JMHelpers circleRadius],
                      [JMHelpers columnHeight]);
}

+(CGFloat)borderWidth {
    return BORDER_WIDTH;
}

+(NSInteger)numDrops {
    return FULL_DROP_COUNTER;
}

+(NSString *)gameOverNotification {
    return gameOverNotificationName;
}

+(NSString *)toggleUserInputPauseNotification {
    return toggleUserInputPauseNotificationName;
}

+(NSString *)gameRestartNotification {
    return gameRestartNotificationName;
}

+(NSString *)gameResetNotificationName {
    return gameResetNotificationName;
}

+(NSString *)currentScoreUpdateNotification {
    return currentScoreUpdated;
}

+(NSNumber *)defaultDifficulty {
    return @(DEFAULTDIFFICULTY);
}

+(NSString *)displayNameForGameMode:(GameMode)gameMode {
    switch (gameMode) {
        case kGameModeClassic:
            return @"classic";
            break;
        case kGameModePower:
            return @"power";
            break;
        case kGameModeTimeAttack:
            return @"time-attack";
        default:
            break;
    }
    return nil;
}

+(GameMode)gameModeForDisplayName:(NSString *)displayName {
    if ([displayName isEqualToString:@"classic"]) return kGameModeClassic;
    if ([displayName isEqualToString:@"power"]) return kGameModePower;
    if ([displayName isEqualToString:@"time-attack"]) return kGameModeTimeAttack;
    return kGameModeClassic;
}

+(NSArray *)gameModes {
    return @[@"classic", @"power", @"time-attack"];
}

+(GameDifficulty)gameDifficultyForDisplayName:(NSString *)displayName {
    return (GameDifficulty)[[self gameDifficulties] indexOfObject:displayName];
}

+(NSString *)displayNameForGameDifficulty:(GameDifficulty)gameDifficulty {
    return [self gameDifficulties][gameDifficulty];
}

+(NSArray *)gameDifficulties {
    return @[@"easy", @"less easy", @"harder", @"more harder", @"insane"];
}
@end
