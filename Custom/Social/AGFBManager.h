//
//  AGFBManager.h
//  123dressme
//
//  Created by Andrei Gubceac on 10/25/13.
//  Copyright (c) 2013 123DressMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@interface AGFBManager : NSObject
@property (nonatomic, readonly, strong) id<FBGraphUser> me;
@property (nonatomic, readonly) NSString *accessToken;

- (BOOL)handleOpenURL:(NSURL*)url;
- (BOOL)isLogged;
- (void)logout;

- (void)authorizeToGetInfoAboutMeWithCompleteBlock:(void(^)(id<FBGraphUser>, NSError*))cblock;
- (void)shareFeedWithDictionary:(id)pd withCompletBlock:(void(^)(NSError*))cblock;
- (void)sendAppRequestTo:(NSArray*)profile_ids message:(NSString*)message withCompletBlock:(void(^)(bool, NSError*))cblock;

@end
