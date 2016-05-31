//
//  AppState.m
//  appBasketball
//
//  Created by iMac on 5/31/16.
//  Copyright © 2016 Marshall. All rights reserved.
//

#import "AppState.h"

@implementation AppState

+ (AppState *)sharedInstance {
    static AppState *sharedMyInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyInstance = [[self alloc] init];
    });
    return sharedMyInstance;
}

@end
