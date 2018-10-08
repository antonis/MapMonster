//
//  GameStatus.h
//  GeoGame
//
//  Created by Antonis Lilis on 3/22/16.
//  Copyright © 2016 Antonis Lilis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle.h>

#define LIVES 5

#define TIMER_DURATION_MIN 10
#define TIMER_DURATION_MAX 30
#define TIMER_DURATION_STEP 5

#define PLACES_PER_LEVEL 10

#define STAR_MIN_WINS 5
#define STAR_MAX_WINS 10
#define LIFE_MIN_WINS 2
#define LIFE_MAX_WINS 10
#define LIFE_PER_STARS 3

@interface GameStatus : MTLModel <MTLJSONSerializing>

- (void) reset;
- (void) updateScoreWithAnswer:(BOOL) correct atRemainingDurationInSeconds:(int) seconds;

- (BOOL) isGameOver;

- (int) getTimerDuration;

- (NSString *) scoreString;
- (NSString *) gameOverString;
- (NSString *) livesString;
- (NSString *) starsString;
- (NSString *) levelString;

- (BOOL) wonDouble;
- (BOOL) wonStar;
- (BOOL) wonLife;

- (void) reportToGameCenter;

@property (nonatomic) int score;
@property (nonatomic) int lives;
@property (nonatomic) int places;
@property (nonatomic) int wins;
@property (nonatomic) int level;
@property (nonatomic) int levelWins;
@property (nonatomic) int consecutiveWins;
@property (nonatomic) int stars;

@end