//
//  MeasurementHelper.m
//  appBasketball
//
//  Created by iMac on 5/31/16.
//  Copyright © 2016 Marshall. All rights reserved.
//

#import "MeasurementHelper.h"
@import Firebase;

@implementation MeasurementHelper

+ (void)sendLoginEvent {
    [FIRAnalytics logEventWithName:kFIREventLogin parameters:nil];
}

+ (void)sendLogoutEvent {
    [FIRAnalytics logEventWithName:@"logout" parameters:nil];
}

+ (void)sendMessageEvent{
    [FIRAnalytics logEventWithName:@"message" parameters:nil];
}
@end
