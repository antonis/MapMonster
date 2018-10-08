//
//  MenuViewController.m
//  GeoGame
//
//  Created by Antonis Lilis on 3/16/16.
//  Copyright © 2016 Antonis Lilis. All rights reserved.
//

#import "MenuViewController.h"
#import "BFPaperButton.h"
#import "AppDelegate.h"
#import "TRZSlideLicenseViewController.h"
#import "IASKAppSettingsViewController.h"
#import "JSQSystemSoundPlayer.h"
#import "SIAlertView.h"
#import "GeoHelper.h"

#define MARGIN 10.0
#define BUTTON_HEIGHT 50.0
#define BOTTOM_MARGIN 35.0
#define TOP_MARGIN 25.0

@interface MenuViewController () {
    NSMutableArray *buttons;
}

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[GameCenterManager sharedManager] setDelegate:self];
    
    self.view.backgroundColor = [UIColor paperColorLightBlue];
    [self addButtonWithTitle:NSLocalizedString(@"play_button", nil) andAction:@selector(play:) atBottomIndex:4 withColor:[UIColor paperColorDeepOrange]];
    [self addButtonWithTitle:NSLocalizedString(@"new_game_button", nil) andAction:@selector(newGame:) atBottomIndex:3 withColor:[UIColor paperColorDeepOrange]];
    [self addButtonWithTitle:NSLocalizedString(@"highscores_button", nil) andAction:@selector(highscores:) atBottomIndex:2 withColor:[UIColor paperColorDeepOrange]];
    [self addButtonWithTitle:NSLocalizedString(@"settings_button", nil) andAction:@selector(settings:) atBottomIndex:1 withColor:[UIColor paperColorDeepOrange]];
    [self addButtonWithTitle:NSLocalizedString(@"credits_button", nil) andAction:@selector(credits:) atBottomIndex:0 withColor:[UIColor paperColorDeepOrange]];
    [self showVersion];
}

- (void) viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void) viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void) addButtonWithTitle:(NSString*) title andAction:(SEL)action atBottomIndex:(int)index withColor:(UIColor*) color {
    if(!buttons) buttons = [[NSMutableArray alloc] init];
    BFPaperButton *button = [[BFPaperButton alloc] initWithFrame:CGRectMake(MARGIN, HEIGHT - (index+1)*BUTTON_HEIGHT - index*MARGIN - BOTTOM_MARGIN, WIDTH - 2*MARGIN, BUTTON_HEIGHT) raised:YES];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    button.backgroundColor = color;
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button];
}

- (void) showVersion {
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN, HEIGHT - 2*MARGIN, 5*MARGIN, MARGIN)];
    versionLabel.font = [UIFont systemFontOfSize:13];
    versionLabel.textAlignment = NSTextAlignmentLeft;
    versionLabel.text = [NSString stringWithFormat:@"v%@",version];
    [self.view addSubview:versionLabel];
}

#pragma mark - button actions

-(void)play:(UIButton*)sender {
    NSLog(@"play");
    [Utils playKeySound];
    [self performSegueWithIdentifier:@"play_segue" sender:sender];
}

-(void)newGame:(UIButton*)sender {
    NSLog(@"newGame");
    SIAlertView *alert = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"new_game_alert_title", nil)
                                                 andMessage:NSLocalizedString(@"new_game_alert_message", nil)
                          ];
    [alert addButtonWithTitle:NSLocalizedString(@"new_game_yes", nil)
                         type:SIAlertViewButtonTypeCancel
                      handler:^(SIAlertView *alert) {
                          [Utils clearGameStatus];
                          [self play:sender];
                      }];
    [alert addButtonWithTitle:NSLocalizedString(@"new_game_no", nil)
                         type:SIAlertViewButtonTypeDestructive
                      handler:^(SIAlertView *alert) {
                          //just dismiss
                      }];
    alert.transitionStyle = SIAlertViewTransitionStyleBounce;
    [alert show];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    GameViewController *controller = [segue destinationViewController];
    controller.status = [Utils gameStatus];
}


-(void)highscores:(UIButton*)sender {
    NSLog(@"highscores");
    [[GameCenterManager sharedManager] presentLeaderboardsOnViewController:self];
}

-(void)settings:(UIButton*)sender {
    NSLog(@"settings");
    IASKAppSettingsViewController *controller = [[IASKAppSettingsViewController alloc] init];
    controller.showDoneButton = NO;
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)credits:(UIButton*)sender {
    NSLog(@"credits");
    TRZSlideLicenseViewController *controller = [[TRZSlideLicenseViewController alloc] init];
    controller.podsPlistName = @"Pods-GeoGame-acknowledgements.plist";
    controller.navigationItem.title = NSLocalizedString(@"credits_title", nil);;
    controller.headerType = TRZSlideLicenseViewHeaderTypeCustom;
    controller.headerTitle = NSLocalizedString(@"copyright", nil);
    controller.headerText = NSLocalizedString(@"credits_text", nil);
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark  - GameCenterManager Delegate

- (void)gameCenterManager:(GameCenterManager *)manager authenticateUser:(UIViewController *)gameCenterLoginController {
    [self presentViewController:gameCenterLoginController animated:YES completion:^{
        NSLog(@"Finished Presenting Authentication Controller");
    }];
}

- (void)gameCenterManager:(GameCenterManager *)manager didSaveScore:(GKScore *)score {
    NSLog(@"Saved GCM Score with value: %lld", score.value);
}

- (void)gameCenterManager:(GameCenterManager *)manager reportedScore:(GKScore *)score withError:(NSError *)error {
    if (!error) {
        NSLog(@"GCM Reported Score: %@", score);
    } else {
        NSLog(@"GCM Error while reporting score: %@", error);
    }
}

- (void)gameCenterManager:(GameCenterManager *)manager didSaveAchievement:(GKAchievement *)achievement {
    NSLog(@"Saved GCM Achievement: %@", achievement);
}

- (void)gameCenterManager:(GameCenterManager *)manager error:(NSError *)error {
    NSLog(@"GCM Error: %@", error);
}

- (void)gameCenterManager:(GameCenterManager *)manager reportedAchievement:(GKAchievement *)achievement withError:(NSError *)error {
    if (!error) {
        NSLog(@"GCM Reported Achievement: %@", achievement);
    } else {
        NSLog(@"GCM Error while reporting achievement: %@", error);
    }
}

- (void)gameCenterManager:(GameCenterManager *)manager availabilityChanged:(NSDictionary *)availabilityInformation {
    NSLog(@"GC Availabilty: %@", availabilityInformation);
}

#pragma mark - GameKit Delegate

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (gameCenterViewController.viewState == GKGameCenterViewControllerStateAchievements) {
        NSLog(@"Displayed GameCenter achievements.");
    } else if (gameCenterViewController.viewState == GKGameCenterViewControllerStateLeaderboards) {
        NSLog(@"Displayed GameCenter leaderboard.");
    } else {
        NSLog(@"Displayed GameCenter controller.");
    }
}

@end
