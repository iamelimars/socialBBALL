//
//  AppState.h
//  appBasketball
//
//  Created by iMac on 5/31/16.
//  Copyright © 2016 Marshall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppState : NSObject

+ (AppState *)sharedInstance;

@property (nonatomic) BOOL signedIn;
@property (nonatomic, retain) NSString *displayName;
@property (nonatomic, retain) NSURL *photoUrl;


@end
