//
//  AGAppDelegate.h
//
//  Created by Andrei Gubceac on 9/10/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AGStorageManager;
@interface AGAppDelegate : UIResponder <UIApplicationDelegate>
{
    AGStorageManager *_storageManager;
}
@property (strong, nonatomic)   UIWindow *window;
@property (readonly, nonatomic) id storageManager;//Instance of AGStorage Manager

+ (AGAppDelegate*)shared;

@end

@interface AGAppDelegate (AppSession)
+ (void)processError:(NSError*)err;
- (void)openAppSession;
- (void)closeAppSession;
@end