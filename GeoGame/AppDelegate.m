//
//  AppDelegate.m
//  GeoGame
//
//  Created by Antonis Lilis on 06/03/16.
//  Copyright © 2016 Antonis Lilis. All rights reserved.
//

#import "AppDelegate.h"
#import "GameCenterManager.h"
#import "Appirater.h"
@import GoogleMaps;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //SSKeychain setup
    [SSKeychain setAccessibilityType:kSecAttrAccessibleWhenUnlocked];
    //GMSServices setup
    [GMSServices provideAPIKey:@"YOUR_API_KEY"];
    //GameCenterManager setup
    [[GameCenterManager sharedManager] setupManagerAndSetShouldCryptWithKey:[Utils getTokenForService:@"gamecentermanager"]];
    //Appirater setup
    [Appirater setAppId:@"YOUR_APP_ID"];
    [Appirater setDaysUntilPrompt:7];
    [Appirater setUsesUntilPrompt:5];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setDebug:NO];
    [Appirater appLaunched:YES];
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self.gameViewController saveAndClose];
}

@end
