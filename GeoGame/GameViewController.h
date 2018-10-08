//
//  GameViewController.h
//  GeoGame
//
//  Created by Antonis Lilis on 06/03/16.
//  Copyright © 2016 Antonis Lilis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JSKTimerView/JSKTimerView.h>
#import "GameStatus.h"
@import GoogleMaps;

@interface GameViewController : UIViewController <GMSPanoramaViewDelegate, JSKTimerViewDelegate>

@property (nonatomic, retain) GameStatus *status;

- (void) pauseGame;
- (void) resumeGame;
- (void) saveAndClose;

@end

