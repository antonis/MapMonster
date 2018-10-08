//
//  AppDelegate.h
//  GeoGame
//
//  Created by Antonis Lilis on 06/03/16.
//  Copyright © 2016 Antonis Lilis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utils.h"
#import "GameViewController.h"
#import "SSKeychain.h"

#define APPDELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

#define SOUNDS_ENABLED ([[NSUserDefaults standardUserDefaults] objectForKey:@"sounds"]==nil?YES:[[[NSUserDefaults standardUserDefaults] objectForKey:@"sounds"] boolValue])
#define TRIVIA_ENABLED ([[NSUserDefaults standardUserDefaults] objectForKey:@"trivia"]==nil?YES:[[[NSUserDefaults standardUserDefaults] objectForKey:@"trivia"] boolValue])

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) GameViewController *gameViewController;

@end

