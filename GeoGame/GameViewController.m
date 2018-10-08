//
//  GameViewController.m
//  GeoGame
//
//  Created by Antonis Lilis on 06/03/16.
//  Copyright © 2016 Antonis Lilis. All rights reserved.
//

#import "GameViewController.h"
#import "GeoHelper.h"
#import "Place.h"
#import "RandomUtils.h"
#import "BFPaperButton.h"
#import "SIAlertView.h"
#import "Reachability.h"
#import "UIView+Toast.h"
#import "WikipediaExtractor.h"
#import "AppDelegate.h"

#define MARGIN 10.0
#define BUTTON_HEIGHT 50.0
#define BOTTOM_MARGIN 35.0
#define TOP_MARGIN 25.0
#define TIMER_SIZE 50.0
#define SCORE_HEIGHT 50.0
#define CLOSE_WIDTH 48.0
#define CLOSE_HEIGHT 48.0
#define ROW_HEIGHT 25.0
#define CORRECT_TOAST_DURATION 5.0
#define WRONG_TOAST_DURATION 8.0
#define TRIVIA_TOAST_DURATION 30.0

@interface GameViewController () {
    GMSPanoramaView *panoView;
    JSKTimerView *timerView;
    UILabel *scoreLabel;
    UILabel *livesLabel;
    UILabel *starsLabel;
    UILabel *levelLabel;
    BFPaperButton *beamMeButton1;
    BFPaperButton *beamMeButton2;
    Place *currentPlace;
    Reachability* reachability;
    BOOL isGameOver;
    BOOL isShowingAlertOrToast;
    
    //Stats for failed Streetview moves
    int totalAttempts;
    int failedAttempts;
}

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    APPDELEGATE.gameViewController = self;
    
    totalAttempts = 0;
    failedAttempts = 0;
    
    reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
    reachability.reachableOnWWAN = YES;
    
    panoView = [[GMSPanoramaView alloc] initWithFrame:CGRectZero];
    panoView.streetNamesHidden = YES;
    panoView.navigationLinksHidden = YES;
    panoView.navigationGestures = NO;
    panoView.zoomGestures = NO;
    panoView.delegate = self;
    self.view = panoView;
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(MARGIN, TOP_MARGIN, CLOSE_WIDTH, CLOSE_HEIGHT)];
    [closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchDown];
    
    beamMeButton1 = [[BFPaperButton alloc] initWithFrame:CGRectMake(MARGIN, HEIGHT - 2*BUTTON_HEIGHT - MARGIN - BOTTOM_MARGIN, WIDTH - 2*MARGIN, BUTTON_HEIGHT) raised:YES];
    [beamMeButton1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [beamMeButton1 setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [beamMeButton1 addTarget:self action:@selector(beamAction:) forControlEvents:UIControlEventTouchDown];
    
    beamMeButton2 = [[BFPaperButton alloc] initWithFrame:CGRectMake(MARGIN, HEIGHT - BUTTON_HEIGHT - BOTTOM_MARGIN, WIDTH - 2*MARGIN, BUTTON_HEIGHT) raised:YES];
    [beamMeButton2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [beamMeButton2 setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [beamMeButton2 addTarget:self action:@selector(beamAction:) forControlEvents:UIControlEventTouchDown];
    
    timerView = [[JSKTimerView alloc] initWithFrame:CGRectMake(WIDTH - TIMER_SIZE - MARGIN, TOP_MARGIN, TIMER_SIZE, TIMER_SIZE)];
    timerView.delegate = self;
    timerView.labelTextColor = [UIColor paperColorGreen50];
    
    scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(2*MARGIN + CLOSE_WIDTH, TOP_MARGIN, WIDTH - 3*MARGIN - CLOSE_WIDTH - TIMER_SIZE, SCORE_HEIGHT)];
    scoreLabel.font = [UIFont systemFontOfSize:21];
    scoreLabel.textAlignment = NSTextAlignmentLeft;
    
    livesLabel = [[UILabel alloc] initWithFrame:CGRectMake(2*MARGIN + CLOSE_WIDTH, TOP_MARGIN, WIDTH - 3*MARGIN - CLOSE_WIDTH - TIMER_SIZE, SCORE_HEIGHT)];
    livesLabel.font = [UIFont systemFontOfSize:21];
    livesLabel.textAlignment = NSTextAlignmentRight;
    livesLabel.textColor = [UIColor redColor];
    
    starsLabel = [[UILabel alloc] initWithFrame:CGRectMake(livesLabel.frame.origin.x, livesLabel.frame.origin.y + ROW_HEIGHT, livesLabel.frame.size.width, livesLabel.frame.size.height)];
    starsLabel.font = [UIFont systemFontOfSize:21];
    starsLabel.textAlignment = NSTextAlignmentRight;
    starsLabel.textColor = [UIColor yellowColor];
    
    levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(scoreLabel.frame.origin.x, scoreLabel.frame.origin.y + ROW_HEIGHT, scoreLabel.frame.size.width, scoreLabel.frame.size.height)];
    levelLabel.font = [UIFont systemFontOfSize:21];
    levelLabel.textAlignment = NSTextAlignmentLeft;
    
    [self.view addSubview:closeButton];
    [self.view addSubview:timerView];
    [self.view addSubview:scoreLabel];
    [self.view addSubview:livesLabel];
    [self.view addSubview:starsLabel];
    [self.view addSubview:levelLabel];
    [self.view addSubview:beamMeButton1];
    [self.view addSubview:beamMeButton2];
    
    [self setStatusLabels];
    [self beamMe];
}

- (void) resetGame {
    [self.status reset];
    [self setStatusLabels];
    [self beamMe];
}

- (void) pauseGame {
    NSLog(@"pauseGame");
    [timerView pauseTimer];
}

- (void) resumeGame {
    NSLog(@"resumeGame");
    if (isShowingAlertOrToast) return;
    if (isGameOver) return;
    [timerView startTimer];
}

- (void) closeAction:(UIButton*)sender {
    NSLog(@"closeAction");
    if (isShowingAlertOrToast) return;
    [self saveAndClose];
}

- (void) saveAndClose {
    [self saveGame];
    [self pauseGame];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)beamAction:(UIButton*)sender {
    NSLog(@"beamAction");
    [timerView pauseTimer];
    if(currentPlace) {
        NSString *selected = ((UIButton*)sender).titleLabel.text;
        NSLog(@"beamAction.selected = %@", selected);
        BOOL correct = [selected isEqualToString:currentPlace.country];
        [self updateScoreWithAnswer:correct];
        [self showAnswerAlert:correct];
        return;
    }
    [self beamMe];
}

- (void) showAnswerAlert:(BOOL) correct {
    if (correct) {
        [Utils playCorrectSound];
    } else {
        [Utils playWrongSound];
    }
    beamMeButton1.enabled = NO;
    beamMeButton2.enabled = NO;
    isShowingAlertOrToast = YES;
    [self.view makeToast:[self getAnswerAlertMessage:correct]
                duration:TRIVIA_ENABLED?TRIVIA_TOAST_DURATION:(correct?CORRECT_TOAST_DURATION:WRONG_TOAST_DURATION)
                position:CSToastPositionCenter
                   title:currentPlace.country
                   image:[self getAnswerAlertImage:correct]
                   style:nil
              completion:^(BOOL didTap) {
                  if (didTap) {
                      NSLog(@"completion from tap");
                      isShowingAlertOrToast = NO;
                      [self checkStatusContinue];
                  } else {
                      NSLog(@"completion by time");
                      isShowingAlertOrToast = NO;
                      [self checkStatusContinue];
                  }
              }];
    
}

- (UIImage *) getAnswerAlertImage:(BOOL)correct {
    if (correct) {
        if ([self.status wonDouble]) {
            return [UIImage imageNamed:@"double.png"];
        } else if ([self.status wonLife]) {
            return [UIImage imageNamed:@"heart.png"];
        } else if ([self.status wonStar]) {
            return [UIImage imageNamed:@"star.png"];
        } else {
            return [UIImage imageNamed:@"correct.png"];
        }
    }
    return [UIImage imageNamed:@"wrong.png"];
}

- (NSString*) getAnswerAlertMessage:(BOOL)correct {
    if (TRIVIA_ENABLED) {
        return currentPlace.trivia;
    }
    return [NSString stringWithFormat:correct?NSLocalizedString(@"answer_text_correct",nil):NSLocalizedString(@"answer_text_wrong", nil), currentPlace.country];
}

- (void) checkStatusContinue {
    if ([self.status isGameOver]) {
        isGameOver = YES;
        [timerView pauseTimer];
        isShowingAlertOrToast = YES;
        SIAlertView *alert = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"game_over_title", nil)
                                                     andMessage:[self.status gameOverString]
                              ];
        [alert addButtonWithTitle:NSLocalizedString(@"close", nil)
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alert) {
                              isShowingAlertOrToast = NO;
                              [self dismissViewControllerAnimated:YES completion:nil];
                          }];
        [alert addButtonWithTitle:NSLocalizedString(@"play_again", nil)
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alert) {
                              isGameOver = NO;
                              isShowingAlertOrToast = NO;
                              [self resetGame];
                              [alert dismissAnimated:YES];
                          }];
        alert.transitionStyle = SIAlertViewTransitionStyleBounce;
        [alert show];
        
        [self saveGame];
    } else {
        [self beamMe];
    }
}

- (void) saveGame {
    [self.status reportToGameCenter];
}

- (void) beamMe {
    if (isGameOver) return;
    totalAttempts++;
    currentPlace = [GeoHelper randomStreetviewPlace];
    int radius = 0;
    CLLocationCoordinate2D point = CLLocationCoordinate2DMake(currentPlace.latitude,currentPlace.longitute);
    if (currentPlace.randomLocationNear) {
        radius = [GeoHelper randomRadius];
        point = [GeoHelper randomPointNear:CLLocationCoordinate2DMake(currentPlace.latitude,currentPlace.longitute)];
    }
    NSLog(@"beamMe (r=%d, (%f, %f)) @ %@", radius, point.latitude, point.longitude, currentPlace);
    [self.view makeToastActivity:CSToastPositionCenter];
    [panoView moveNearCoordinate:point radius:radius];
}

- (void) updateScoreWithAnswer:(BOOL) correct {
    [self.status updateScoreWithAnswer:correct atRemainingDurationInSeconds:(int)timerView.remainingDurationInSeconds];
    [self setStatusLabels];
}

- (void) setStatusLabels {
    scoreLabel.text = [self.status scoreString];
    livesLabel.text = [self.status livesString];
    starsLabel.text = [self.status starsString];
    levelLabel.text = [self.status levelString];
}

-(BOOL)checkRechability {
    if(![reachability isReachable]) {
        [self pauseGame];
        isShowingAlertOrToast = YES;
        SIAlertView *noNetworkAlert = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"error_title", nil)
                                                              andMessage:NSLocalizedString(@"error_connection", nil)];
        noNetworkAlert.transitionStyle = SIAlertViewTransitionStyleBounce;
        [noNetworkAlert addButtonWithTitle:NSLocalizedString(@"close", nil)
                                      type:SIAlertViewButtonTypeCancel
                                   handler:^(SIAlertView *alert) {
                                       isShowingAlertOrToast = NO;
                                       [self dismissViewControllerAnimated:YES completion:nil];
                                   }];
        [noNetworkAlert addButtonWithTitle:NSLocalizedString(@"retry", nil)
                                      type:SIAlertViewButtonTypeDestructive
                                   handler:^(SIAlertView *alert) {
                                       isShowingAlertOrToast = NO;
                                       if ([self checkRechability]) {
                                           [self beamMe];
                                       }
                                   }];
        [noNetworkAlert show];
        return NO;
    }
    return YES;
}

#pragma mark GMSPanoramaViewDelegate

- (void)panoramaView:(GMSPanoramaView *)view didMoveToPanorama:(GMSPanorama *)panorama nearCoordinate:(CLLocationCoordinate2D)coordinate {
    NSLog(@"SUCCESS.didMoveTo(%f, %f): %@", coordinate.latitude, coordinate.longitude, panorama.panoramaID);
    if(TRIVIA_ENABLED) {
        [WikipediaExtractor fetchInfoFor:currentPlace];
    }
    [self.view hideToastActivity];
    Place *otherPlace = [GeoHelper randomStreetviewPlaceOtherThan:currentPlace];
    beamMeButton1.backgroundColor = [Utils randomColor];
    beamMeButton2.backgroundColor = [Utils randomColorButNot:beamMeButton1.backgroundColor];
    if([RandomUtils randomEventOccurs: 50.0]) {
        [beamMeButton1 setTitle:currentPlace.country forState:UIControlStateNormal];
        [beamMeButton2 setTitle:otherPlace.country forState:UIControlStateNormal];
    } else {
        [beamMeButton2 setTitle:currentPlace.country forState:UIControlStateNormal];
        [beamMeButton1 setTitle:otherPlace.country forState:UIControlStateNormal];
    }
    [timerView setTimerWithDuration:[self.status getTimerDuration]];
    [timerView resetTimer];
    [timerView startTimer];
    beamMeButton1.enabled = YES;
    beamMeButton2.enabled = YES;
}

- (void)panoramaView:(GMSPanoramaView *)view error:(NSError *)error onMoveNearCoordinate:(CLLocationCoordinate2D)coordinate  {
    NSLog(@"ERROR.onMoveNearCoordinate.Retrying... %d / %d (%.2f%% failure)", ++failedAttempts, totalAttempts, (float)failedAttempts/(float)totalAttempts*100);
    if([self checkRechability]){
        [self beamMe]; //Retry
    }
}

#pragma mark JSKTimerViewDelegate

- (void)timerDidFinish:(JSKTimerView *)timerView {
    NSLog(@"timerDidFinish");
    [self updateScoreWithAnswer:NO];
    [self showAnswerAlert:NO];
}

@end