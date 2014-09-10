//
//  AGAppDelegate.h
//
//  Created by Andrei Gubceac on 9/10/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AGStorageManager;

@interface AGAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (readonly, nonatomic) AGStorageManager    *storageManager;

+ (AGAppDelegate*)shared;

@end

@interface AGAppDelegate (AppSession)
+ (void)processError:(NSError*)err;
- (void)openAppSession;
- (void)closeAppSession;
@end