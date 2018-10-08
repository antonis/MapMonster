//
//  WikipediaExtractor.m
//  GeoGame
//
//  Created by Antonis Lilis on 29/05/16.
//  Copyright © 2016 Antonis Lilis. All rights reserved.
//

#import "WikipediaExtractor.h"
#import "AFNetworking.h"
#import "Utils.h"

#define TRIVIA_MAX_LENGTH 420

@implementation WikipediaExtractor

+ (void) fetchInfoFor:(Place*) place {    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:@"https://en.wikipedia.org//w/api.php"
      parameters:@{ @"action": @"query",
                    @"format": @"json",
                    @"prop": @"extracts",
                    @"exsectionformat": @"plain",
                    @"exsentences": @2,
                    @"explaintext": @1,
                    @"titles": place.country }
        progress:nil
         success:^(NSURLSessionTask *task, id responseObject) {
             NSLog(@"WikipediaExtractor.JSON: %@", responseObject);
             NSDictionary *query = [responseObject objectForKey:@"query"];
             if(query != nil) {
                 NSDictionary *pages = [query objectForKey:@"pages"];
                 if(pages != nil && [[pages allKeys] count]>0) {
                     NSString *pageId = [[pages allKeys] objectAtIndex:0];
                     NSDictionary *result = [pages objectForKey:pageId];
                     if (result != nil) {
                         NSString *extract = [result objectForKey:@"extract"];
                         place.trivia = @"";
                         if(extract != nil) {
                             NSString *trimmedDetails = [Utils removeSubstringsInParenthesisFrom:extract];
                             if([trimmedDetails length] > TRIVIA_MAX_LENGTH) {
                                 place.trivia = [NSString stringWithFormat:@"%@...",[trimmedDetails substringToIndex:TRIVIA_MAX_LENGTH]];
                             } else {
                                 place.trivia = trimmedDetails;
                             }
                         }
                         
                     }
                 }
             }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"WikipediaExtractor.Error: %@", error);
    }];
    
}

@end
