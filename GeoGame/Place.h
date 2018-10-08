//
//  Place.h
//  GeoGame
//
//  Created by Antonis Lilis on 28/03/16.
//  Copyright © 2016 Antonis Lilis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mantle.h>

@interface Place : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *country;
@property (nonatomic) double longitute;
@property (nonatomic) double latitude;
@property (nonatomic) BOOL randomLocationNear;
@property (nonatomic, copy) NSString *trivia;

@end