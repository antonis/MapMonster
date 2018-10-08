//
//  GeoHelper.m
//  GeoGame
//
//  Created by Antonis Lilis on 3/13/16.
//  Copyright © 2016 Antonis Lilis. All rights reserved.
//

#import "GeoHelper.h"
#import "RandomUtils.h"

#define MAX_RADIUS 5000
#define POINT_VARIATION 0.5

@interface GeoHelper () {
}

@property (nonatomic, retain) NSArray *countryCapitals;
@property (nonatomic, retain) NSArray *heritageSites;
@property (nonatomic, retain) NSArray *streetviewCoverage;
@property (nonatomic, retain) NSArray *currentPlacesCollection;

@end

@implementation GeoHelper

+ (GeoHelper*)sharedInstance {
    static GeoHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (Place *) randomStreetviewPlace {
    int randomIndex = [RandomUtils randomIntBetweenMin:0 andMax:[[GeoHelper sharedInstance].streetviewCoverage count]-1.0];
    NSString *randomStreetViewCountry = [[GeoHelper sharedInstance].streetviewCoverage objectAtIndex:randomIndex];
    for (Place *place in [GeoHelper sharedInstance].currentPlacesCollection) {
        if ([randomStreetViewCountry isEqualToString:place.country]) {
            return place;
        }
    }
    return [GeoHelper randomStreetviewPlace]; //Retry
}

+ (Place *) randomStreetviewPlaceOtherThan:(Place *)current {
    Place *random = [GeoHelper randomStreetviewPlace];
    if ([random.country isEqualToString:current.country]) {
        return [GeoHelper randomStreetviewPlaceOtherThan:current];
    }
    return random;
}

+ (int) randomRadius {
    return [RandomUtils randomIntBetweenMin:0 andMax:MAX_RADIUS];
}

+ (CLLocationCoordinate2D) randomPointNear:(CLLocationCoordinate2D)coordinate {
    float latRandomFactor = [RandomUtils randomFloatBetweenMin:-POINT_VARIATION andMax:POINT_VARIATION];
    float lonRandomFactor = [RandomUtils randomFloatBetweenMin:-POINT_VARIATION andMax:POINT_VARIATION];
    return CLLocationCoordinate2DMake(coordinate.latitude + latRandomFactor, coordinate.longitude + lonRandomFactor);
}

- (id)init {
    if (self = [super init]) {
        self.streetviewCoverage = [self objectsOfType:NSString.class fromJSONResource:@"geodata/streetview"];
        self.countryCapitals = [self placesWithRandomLocationEnabled:YES fromJSONResource:@"geodata/country-capitals"];
        self.heritageSites = [self placesWithRandomLocationEnabled:NO fromJSONResource:@"geodata/heritage"];
        self.currentPlacesCollection = self.countryCapitals;
    }
    return self;
}

- (NSArray *) placesWithRandomLocationEnabled:(BOOL) randomLocation fromJSONResource:(NSString*)jsonResourceFile {
    NSArray *places = [self objectsOfType:Place.class fromJSONResource:jsonResourceFile];
    for (Place *place in places) place.randomLocationNear = randomLocation;
    return places;
}

- (NSArray *) objectsOfType:(Class)modelClass fromJSONResource:(NSString*)jsonResourceFile {
    NSString * filePath =[[NSBundle mainBundle] pathForResource:jsonResourceFile ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    if ([modelClass conformsToProtocol:@protocol(MTLJSONSerializing)]) {
        NSArray *objectArray = [MTLJSONAdapter modelsOfClass:modelClass fromJSONArray:json error:nil];
        return objectArray;
    }
    return json;
}

@end
