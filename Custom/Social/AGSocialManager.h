//
//  AGSocialManager.h
//
//  Created by Andrei Gubceac on 2/11/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
//#import <Pinterest/Pinterest.h>
//#import <GooglePlus/GPPSignIn.h>
//#import <GooglePlus/GPPShare.h>
#import <FacebookSDK/FacebookSDK.h>

@interface AGSocialManager : NSObject
+ (AGSocialManager*)shared;
+ (NSString*)pinterestId;

+ (void)processError:(NSError*)err;
+ (void)deleteCookies;
+ (BOOL)handleURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

- (void)sendViaEmailTo:(NSArray *)tos subject:(NSString*)subject
              withBody:(id)messageBody
    fromViewController:(UIViewController*)viewController//pass nil to user window.rootViewController;
     withCompleteBlock:(void (^)(NSError *))block;

- (void)sendViaSMSWithBody:(id)body withCompleteBlock:(void(^)(NSError*))block;
- (void)shareViaFacebookWithTitle:(NSString*)title description:(NSString*)desc url:(NSURL*)link thumbnailURL:(NSURL*)turl thumbnailImage:(UIImage*)timage withCompleteBlock:(void (^)(NSError *))block;
- (void)shareViaTwitterWithInitialText:(NSString*)desc url:(NSURL*)url image:(UIImage*)image withCompleteBlock:(void (^)(NSError *))block;
- (void)shareViaPinterestImageUrl:(NSURL*)imageUrl sourceUrl:(NSURL*)sourceUrl description:(NSString*)desc withCompleteBlock:(void (^)(NSError *))block;
//- (void)shareViaGooglePlusWithTitle:(NSString*)title description:(NSString*)desc url:(NSURL*)link thumbnailURL:(NSURL*)turl withCompleteBlock:(void (^)(NSError *))block;

@end
