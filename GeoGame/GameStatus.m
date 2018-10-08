//
//  GameStatus.m
//  GeoGame
//
//  Created by Antonis Lilis on 3/22/16.
//  Copyright © 2016 Antonis Lilis. All rights reserved.
//

#import "GameStatus.h"
#import "GameCenterManager.h"
#import "Utils.h"

@interface GameStatus () {
    BOOL wonLife;
    BOOL wonStar;
}

@end

@implementation GameStatus 

- (id)init {
    if (self = [super init]) {
        [self reset];
    }
    return self;
}

- (void) reset {
    self.score = 0;
    self.lives = LIVES;
    self.places = 1;
    self.wins = 0;
    self.level = 1;
    self.levelWins = 0;
    self.consecutiveWins = 0;
    self.stars = 0;
}

- (void) updateScoreWithAnswer:(BOOL) correct atRemainingDurationInSeconds:(int) seconds {
    self.places++;
    if (correct) {
        self.wins++;
        self.levelWins++;
        self.consecutiveWins++;
        self.score += seconds;
        [self checkAchievements];
    } else {
        self.consecutiveWins = 0;
        self.lives--;
    }
    if (self.score<0) self.score = 0;
    [self levelStatus];
    [Utils setGameStatus:self];
    NSLog(@"status=%@",self);
}

- (void) levelStatus {
    if (self.places % PLACES_PER_LEVEL == 0) {
        self.level++;
        self.levelWins = 0;
    }
}

- (void) checkAchievements {
    if (self.levelWins == MIN(STAR_MIN_WINS + self.level, STAR_MAX_WINS)){
        self.stars++;
        wonStar = YES;
    }
    if (self.consecutiveWins == MIN(LIFE_MIN_WINS + self.level, LIFE_MAX_WINS)){
        self.lives++;
        wonLife = YES;
    }
    if (self.stars > 0 && self.stars % LIFE_PER_STARS == 0) {
        self.lives++;
        wonLife = YES;
        self.stars = 0;
    }
}

- (BOOL) wonDouble {
    if(wonLife && wonStar) {
        wonLife = NO;
        wonStar = NO;
        return YES;
    }
    return NO;
}

- (BOOL) wonStar {
    if(wonStar) {
        wonStar = NO;
        return YES;
    }
    return NO;
}

- (BOOL) wonLife {
    if(wonLife) {
        wonLife = NO;
        return YES;
    }
    return NO;
}

- (BOOL) isGameOver {
    if (self.lives == 0) {
        [Utils clearGameStatus];
        return YES;
    }
    return NO;
}

- (int) getTimerDuration {
    return MAX(TIMER_DURATION_MIN, TIMER_DURATION_MAX - ((self.level-1)*TIMER_DURATION_STEP));
}

- (NSString *) gameOverString {
    return [NSString stringWithFormat:NSLocalizedString(@"game_over_text", nil),self.score];
}

- (NSString *) scoreString {
    return [NSString stringWithFormat:@"%d",self.score];
}

- (NSString *) livesString {
    if(self.lives>6) //iPhone4 screen limit
        return [NSString stringWithFormat:@"%d♥",self.lives];
    return [Utils repeat:@"♥" times:self.lives];
}

- (NSString *) starsString {
    return [Utils repeat:@"★" times:self.stars];
}

- (NSString *) levelString {
    return [NSString stringWithFormat:@"Level: %d",self.level];
}

- (void) reportToGameCenter {
    [[GameCenterManager sharedManager] saveAndReportScore:self.score leaderboard:@"scores" sortOrder:GameCenterSortOrderHighToLow];
    [[GameCenterManager sharedManager] saveAndReportScore:self.level leaderboard:@"level" sortOrder:GameCenterSortOrderHighToLow];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"score": @"score",
             @"lives": @"lives",
             @"places": @"places",
             @"wins": @"wins",
             @"level": @"level",
             @"levelWins": @"levelWins",
             @"consecutiveWins": @"consecutiveWins",
             @"stars": @"stars"
             };
}

@end