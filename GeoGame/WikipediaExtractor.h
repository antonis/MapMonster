//
//  WikipediaExtractor.h
//  GeoGame
//
//  Created by Antonis Lilis on 29/05/16.
//  Copyright © 2016 Antonis Lilis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Place.h"

@interface WikipediaExtractor : NSObject

+ (void) fetchInfoFor:(Place*) place;

@end
