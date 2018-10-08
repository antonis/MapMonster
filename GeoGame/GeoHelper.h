//
//  GeoHelper.h
//  GeoGame
//
//  Created by Antonis Lilis on 3/13/16.
//  Copyright © 2016 Antonis Lilis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Place.h"
@import CoreLocation;

@interface GeoHelper : NSObject

+ (Place *) randomStreetviewPlace;
+ (Place *) randomStreetviewPlaceOtherThan:(Place *)current;

+ (CLLocationCoordinate2D) randomPointNear:(CLLocationCoordinate2D)coordinate;
+ (int) randomRadius;

@end
