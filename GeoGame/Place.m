//
//  Place.m
//  GeoGame
//
//  Created by Antonis Lilis on 28/03/16.
//  Copyright © 2016 Antonis Lilis. All rights reserved.
//

#import "Place.h"

@implementation Place

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"country": @"country",
             @"name": @"name",
             @"longitute": @"longitute",
             @"latitude": @"latitude"
             };
}

@end
