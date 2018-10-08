//
//  Utils.h
//  GeoGame
//
//  Created by Antonis Lilis on 3/13/16.
//  Copyright © 2016 Antonis Lilis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIColor+BFPaperColors.h"
#import "GameStatus.h"

@interface Utils : NSObject

+ (UIColor *) randomColor;
+ (UIColor *) randomColorButNot:(UIColor*) color;

+ (NSString*) getTokenForService:(NSString*)service;

+ (NSString *) repeat:(NSString*) string times:(int) times;
+ (NSString *) removeSubstringsInParenthesisFrom:(NSString*) string;

+ (void) playKeySound;
+ (void) playCorrectSound;
+ (void) playWrongSound;

+ (GameStatus*) gameStatus;
+ (void) setGameStatus:(GameStatus*) status;
+ (void) clearGameStatus;

@end
