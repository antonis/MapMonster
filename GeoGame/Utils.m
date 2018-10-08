//
//  Utils.m
//  GeoGame
//
//  Created by Antonis Lilis on 3/13/16.
//  Copyright © 2016 Antonis Lilis. All rights reserved.
//

#import "Utils.h"
#import "RandomUtils.h"
#import "JSQSystemSoundPlayer.h"
#import "AppDelegate.h"

@interface Utils () {
}

@property (nonatomic, retain) NSArray *colors;

@end

@implementation Utils

+ (Utils*)sharedInstance {
    static Utils *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        self.colors = [[NSArray alloc] initWithObjects:
                       [UIColor paperColorRed],
                       [UIColor paperColorPink],
                       [UIColor paperColorPurple],
                       [UIColor paperColorDeepPurple],
                       [UIColor paperColorIndigo],
                       [UIColor paperColorBlue],
                       [UIColor paperColorLightBlue],
                       [UIColor paperColorCyan800],
                       [UIColor paperColorTeal],
                       [UIColor paperColorGreen],
                       [UIColor paperColorLightGreen],
                       [UIColor paperColorLime],
                       [UIColor paperColorYellow700],
                       [UIColor paperColorAmber],
                       [UIColor paperColorOrange],
                       [UIColor paperColorDeepOrange],
                       [UIColor paperColorBrown],
                       [UIColor paperColorGray],
                       [UIColor paperColorBlueGray], nil];
    }
    return self;
}

+ (UIColor *) randomColor {
    int randomIndex = [RandomUtils randomIntBetweenMin:0 andMax:[[Utils sharedInstance].colors count]-1.0];
    return [[Utils sharedInstance].colors objectAtIndex:randomIndex];
}

+ (UIColor *) randomColorButNot:(UIColor*) color {
    int randomIndex = [RandomUtils randomIntBetweenMin:0 andMax:[[Utils sharedInstance].colors count]-1.0];
    UIColor *otherColor = [[Utils sharedInstance].colors objectAtIndex:randomIndex];
    if ([otherColor isEqual:color]) {
        return [Utils randomColorButNot:color];
    } else {
        return otherColor;
    }
}

+ (NSString *) repeat:(NSString*) string times:(int) times {
    NSMutableString *temp = [NSMutableString stringWithCapacity:times];
    for (int i = 0; i < times; i++)
        [temp appendString:string];
    return [NSString stringWithString:temp];
}

+ (NSString *) removeSubstringsInParenthesisFrom:(NSString*) string {
    NSString *s = [[string stringByReplacingOccurrencesOfString:@" )" withString:@")"] stringByReplacingOccurrencesOfString:@" (" withString:@"("];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\(.*?\\)" options:NSRegularExpressionCaseInsensitive error:nil];
    return [regex stringByReplacingMatchesInString:s options:0 range:NSMakeRange(0, [s length]) withTemplate:@""];
}

+ (void) playKeySound {
    [[JSQSystemSoundPlayer sharedPlayer] toggleSoundPlayerOn:SOUNDS_ENABLED];
    [[JSQSystemSoundPlayer sharedPlayer] playSoundWithFilename:@"sounds/keypress"
                                                 fileExtension:kJSQSystemSoundTypeWAV
                                                    completion:^{}];
}

+ (void) playCorrectSound {
    [[JSQSystemSoundPlayer sharedPlayer] toggleSoundPlayerOn:SOUNDS_ENABLED];
    [[JSQSystemSoundPlayer sharedPlayer] playSoundWithFilename:@"sounds/correct"
                                                 fileExtension:kJSQSystemSoundTypeWAV
                                                    completion:^{}];
}

+ (void) playWrongSound {
    [[JSQSystemSoundPlayer sharedPlayer] toggleSoundPlayerOn:SOUNDS_ENABLED];
    [[JSQSystemSoundPlayer sharedPlayer] playSoundWithFilename:@"sounds/wrong"
                                                 fileExtension:kJSQSystemSoundTypeWAV
                                                    completion:^{}];
}

// Generate the first time and store in keychain for reuse
+ (NSString*) getTokenForService:(NSString*)service {
    NSString *token = [SSKeychain passwordForService:service account:[[NSBundle mainBundle] bundleIdentifier]];
    if (token == nil) {
        token = [NSString stringWithFormat:@"%@-%@",service,[RandomUtils randomStringNameWithLength:64 useSeed:YES]];
        [SSKeychain setPassword:token forService:service account:[[NSBundle mainBundle] bundleIdentifier]];
    }
    return token;
}

+ (GameStatus*) gameStatus {
    NSString *json = [SSKeychain passwordForService:@"status" account:[[NSBundle mainBundle] bundleIdentifier]];
    if (json == nil) {
        return [[GameStatus alloc] init];
    }
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    id dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    GameStatus *status = [MTLJSONAdapter modelOfClass:GameStatus.class fromJSONDictionary:dict error:nil];
    return status;
}

+ (void) setGameStatus:(GameStatus*) status {
    NSDictionary *JSONDictionary = [MTLJSONAdapter JSONDictionaryFromModel:status error:nil];
    NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:JSONDictionary options:0 error:nil];
    NSString * json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [SSKeychain setPassword:json forService:@"status" account:[[NSBundle mainBundle] bundleIdentifier]];
}

+ (void) clearGameStatus {
    [SSKeychain deletePasswordForService:@"status" account:[[NSBundle mainBundle] bundleIdentifier]];
}

@end
