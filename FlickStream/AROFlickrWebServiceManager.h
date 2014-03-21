//
//  AROFlickrWebServiceManager.h
//  FlickrChallenge
//
//  Created by Joe Goullaud on 2/13/14.
//  Copyright (c) 2014 Aereo, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AROFlickrWebServiceManager : NSObject

+ (instancetype)sharedInstance;

- (void)fetchPublicImagesWithCompletion:(void (^)(NSDictionary *data, NSURLResponse *response, NSError *error))completionBlock;

@end
