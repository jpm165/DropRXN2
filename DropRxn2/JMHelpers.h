//
//  JMHelpers.h
//  DropRxn
//
//  Created by James Mundie on 10/24/16.
//  Copyright © 2016 James Mundie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Circle.h"
#import "Column.h"
#import "JMAnimationManager.h"
#import "DropCounter.h"

@interface JMHelpers : NSObject

+(UIColor *)jmDarkBlueColor;
+(UIColor *)jmDarkRedColor;
+(UIColor *)jmDarkOrangeColor;
+(UIColor *)jmDarkGreenColor;
+(UIColor *)jmDarkGrayColor;
+(UIColor *)jmPurpleColor;

+(UIColor *)jmLightBlueColor;
+(UIColor *)jmLightGreenColor;
+(UIColor *)jmLightGrayColor;

+(UIColor *)columnBGColor;

+(UIColor *)randomColor;
+(int)random;
+(int)randomNonGrey;
+(NSArray *)allColors;

+(CGSize)sizeForText:(NSString *)text inBoundingBox:(CGRect)boundingBox withAttributes:(NSDictionary *)attributes;
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

@end
