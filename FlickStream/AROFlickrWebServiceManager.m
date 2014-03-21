//
//  AROFlickrWebServiceManager.m
//  FlickrChallenge
//
//  Created by Joe Goullaud on 2/13/14.
//  Copyright (c) 2014 Aereo, Inc. All rights reserved.
//

#import "AROFlickrWebServiceManager.h"

@implementation AROFlickrWebServiceManager

+ (instancetype)sharedInstance
{
    static AROFlickrWebServiceManager *s_webManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_webManager = [[self alloc] init];
    });
    
    return s_webManager;
}

- (void)fetchPublicImagesWithCompletion:(void (^)(NSDictionary *data, NSURLResponse *response, NSError *error))completionBlock
{
    NSURL *feedURL = [NSURL URLWithString:@"http://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1"];
    [[[NSURLSession sharedSession] dataTaskWithURL:feedURL completionHandler:^(NSData *feedData, NSURLResponse *feedResponse, NSError *feedError) {
        
        NSError *jsonError = feedError;
        id jsonData = [NSJSONSerialization JSONObjectWithData:feedData options:NSJSONReadingAllowFragments error:&jsonError];
        
        if ([jsonData isKindOfClass:[NSArray class]])
        {
            jsonData = [jsonData firstItem];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            completionBlock(jsonData, feedResponse, jsonError);
        });
    }] resume];
}

@end
