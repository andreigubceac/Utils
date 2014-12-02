//
//  AGSocialManager.m
//
//  Created by Andrei Gubceac on 2/11/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "AGSocialManager.h"

static NSString *_pinterestUrl = @"http://www.pinterest.com";

@interface AGSocialManager ()<MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>//, GPPShareDelegate, GPPSignInDelegate>
{
    id _pinterest;
    id _infoToShareDict;
}
@property (nonatomic, copy) void(^block)(NSError*);
@end

@implementation AGSocialManager

+ (AGSocialManager*)shared
{
    static AGSocialManager *_manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[[self class] alloc] init];
    });
    return _manager;
}

+ (void)deleteCookies
{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSURL *_url = [NSURL URLWithString:_pinterestUrl];
    for (NSHTTPCookie *cookie in [storage cookiesForURL:_url]) {
        [storage deleteCookie:cookie];
    }
}

+ (NSString*)pinterestId
{
    return nil;
}

- (id)pinterest
{
    if (_pinterest)
        return _pinterest;
    return (_pinterest = nil);//[[NSClassFromString(@"Pinterest") alloc] initWithClientId:[[self class] pinterestId]]);//should be a custom Id
}

+ (void)processError:(NSError*)err
{
    if ([err code] == kCFURLErrorNotConnectedToInternet)
    {
        
    }
    else
    {
        if  (err.code == (MFMailComposeResultCancelled | MessageComposeResultCancelled) ||
             err.code == (FBOSIntegratedShareDialogResultCancelled | FBWebDialogResultDialogNotCompleted) ||
             err.code == (SLComposeViewControllerResultCancelled)
//             || err.code == (kGPPErrorShareboxCanceled | kGPPErrorShareboxCanceledByClient)
             )
        {/*nothing to do*/}
        else
        {
            
        }
             }
}


+ (BOOL)handleURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([sourceApplication isEqualToString:@"pinterest"])
    {
        NSString *_pin_result = [[[url query] componentsSeparatedByString:@"="] lastObject];
        NSLog(@"%@",_pin_result);
        return YES;
    }
    NSString *urlString = [url absoluteString];
    if ([[urlString substringToIndex:2] isEqualToString:@"fb"]){
        return [FBSession.activeSession handleOpenURL:url];
    }
    return NO;
}

#pragma mark - MFMailComposeViewControllerDelegate Protocol Implementation

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    // check the result of the send after the viewcontroller is done animating
    [controller dismissViewControllerAnimated:YES completion:^{
        if (self.block)
        {
            if (error)
                self.block(error);
            else
                self.block(result!=MFMailComposeResultSent?[NSError errorWithDomain:@"MFMailComposeResult" code:result userInfo:@{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"%d",result]}]:nil);
        }
    }];
}

#pragma mark - MFMessageComposeViewControllerDelegate Protocol Implementation
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    // check the result of the send after the viewcontroller is done animating
    UIWindow *_w = [[UIApplication sharedApplication].windows firstObject];
    [_w.rootViewController dismissViewControllerAnimated:YES completion:^{
        if (self.block)
        {
            self.block(result!=MessageComposeResultSent?[NSError errorWithDomain:@"MessageComposeResult" code:result userInfo:@{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"%d",result]}]:nil);
        }
    }];
}

#pragma mark - Share Actions

/**
 Attempts to compose and send an email message using the current recipe's
 details
 */

- (void)sendViaEmailTo:(NSArray *)tos subject:(NSString*)subject withBody:(id)messageBody fromViewController:(UIViewController *)viewController withCompleteBlock:(void (^)(NSError *))block
{
    if(![MFMailComposeViewController canSendMail])
    {
        if (block)
            block([NSError errorWithDomain:@"MFMailComposeViewController" code:MFMailComposeResultFailed userInfo:@{NSLocalizedDescriptionKey: @"No email accounts are configured on this device. Please set up an account in the Settings Application."}]);
        return;
    }
    self.block = block;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        //    [[UINavigationBar appearanceWhenContainedIn:[MFMailComposeViewController class], nil]
        //     setBarTintColor:[UIColor blackColor]];
        
        MFMailComposeViewController *controller = [MFMailComposeViewController new];
        controller.mailComposeDelegate = self;
        // set body
        [controller setMessageBody:messageBody isHTML:YES];
        [controller setSubject:subject];
        
        // set Subject
        [controller setSubject:subject];
        [controller setToRecipients:tos];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            if (viewController)
               [viewController presentViewController:controller animated:YES completion:^{
                    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
                }];
            else
            {
                UIWindow *_w = [[UIApplication sharedApplication].windows firstObject];
                UIViewController *_vc = _w.rootViewController;
                if (_vc.presentedViewController)
                    _vc = _vc.presentedViewController;
                [_vc presentViewController:controller animated:YES completion:^(void){
                    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
                }];
            }
        });
    });
}


/**
 Attempts to compose and send an SMS message using the current recipe's details
 */
- (void)sendViaSMSWithBody:(id)body withCompleteBlock:(void (^)(NSError *))block
{
    // check if the device can send a text message
    if(![MFMessageComposeViewController canSendText])
    {
        if (block)
            block([NSError errorWithDomain:@"MFMessageComposeViewController" code:MessageComposeResultFailed userInfo:@{NSLocalizedDescriptionKey: @"This device does not have Text Message capabilities"}]);
        return;
    }
    self.block = block;
    MFMessageComposeViewController * controller = [MFMessageComposeViewController new];
    controller.messageComposeDelegate = self;
    [controller setBody:body];
    UIWindow *_w = [[UIApplication sharedApplication].windows firstObject];
    UIViewController *_vc = _w.rootViewController;
    if (_vc.presentedViewController)
        _vc = _vc.presentedViewController;
    [_vc presentViewController:controller animated:YES completion:^(void){
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
}

/**
 Share on Facebook using their new awesome share dialog
 */
- (void)shareViaFacebookWithTitle:(NSString*)title description:(NSString*)desc url:(NSURL*)link thumbnailURL:(NSURL*)turl thumbnailImage:(UIImage*)timage withCompleteBlock:(void (^)(NSError *))block
{
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    params.link                 = link;
    params.linkDescription      = desc;
    params.picture              = turl;
    if ([FBDialogs canPresentShareDialogWithParams:params])
    {
        [FBDialogs presentShareDialogWithParams:params
                                    clientState:nil
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if (block)
                                              block(error);
                                      }];
    }
    else if ([FBDialogs canPresentOSIntegratedShareDialogWithSession:Nil])
    {
        UIWindow *_w = [[UIApplication sharedApplication].windows firstObject];
        UIViewController *_vc = _w.rootViewController;
        if (_vc.presentedViewController)
            _vc = _vc.presentedViewController;
        [FBDialogs presentOSIntegratedShareDialogModallyFrom:_vc
                                                 initialText:desc?desc:title
                                                       image:timage
                                                         url:link
                                                     handler:^(FBOSIntegratedShareDialogResult result, NSError *error) {
                                                         if (block)
                                                             block(error?error:(result == FBOSIntegratedShareDialogResultCancelled?[NSError errorWithDomain:@"FBOSIntegratedShareDialogResult" code:FBOSIntegratedShareDialogResultCancelled userInfo:@{NSLocalizedDescriptionKey: [@(result) stringValue]}]:nil));
                                                     }];
    }
    else
    {
        NSMutableDictionary* params = [NSMutableDictionary dictionary];
        [params setValue:title forKey:@"name"];
        [params setValue:desc forKey:@"linkDescription"];
        [params setValue:[link absoluteString] forKey:@"link"];
        [params setValue:[turl absoluteString] forKey:@"picture"];
        [FBWebDialogs presentFeedDialogModallyWithSession:Nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (block)
                                                          block(error?error:(result==FBWebDialogResultDialogNotCompleted?[NSError errorWithDomain:@"FBWebDialogResult" code:FBWebDialogResultDialogNotCompleted userInfo:@{NSLocalizedDescriptionKey: @"FBWebDialogResultDialogNotCompleted"}]:nil));
                                                  }];
    }
}

/**
 Share on Twitter using their new awesome share dialog
 */
- (void)shareViaTwitterWithInitialText:(NSString*)desc url:(NSURL*)url image:(UIImage*)image withCompleteBlock:(void (^)(NSError *))block
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *_cvc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        if (url)
            [_cvc addURL:url];
        [_cvc setInitialText:desc];
        [_cvc addImage:image];
        [_cvc setCompletionHandler:^(SLComposeViewControllerResult res){
            UIWindow *_w = [[UIApplication sharedApplication].windows firstObject];
            UIViewController *_vc = _w.rootViewController;
            if (_vc.presentedViewController)
                _vc = _vc.presentedViewController;
            [_vc dismissViewControllerAnimated:YES completion:^{if(block)block(nil);}];
        }];
        UIWindow *_w = [[UIApplication sharedApplication].windows firstObject];
        UIViewController *_vc = _w.rootViewController;
        if (_vc.presentedViewController)
            _vc = _vc.presentedViewController;
        [_vc presentViewController:_cvc animated:YES completion:nil];
    }
    else if (block)
        block([NSError errorWithDomain:@"SLServiceTypeTwitter" code:404 userInfo:@{NSLocalizedDescriptionKey: @"No Twitter accounts are configured on this device. Please set up an account in the Settings Application.", NSLocalizedRecoverySuggestionErrorKey: @"Login to Twitter in Settings"}]);
}

- (void)shareViaPinterestImageUrl:(NSURL*)imageUrl sourceUrl:(NSURL*)sourceUrl description:(NSString*)desc withCompleteBlock:(void (^)(NSError *))block
{
/*
    if ([[[AGSocialManager shared] pinterest] canPinWithSDK])
    {
        if (imageUrl == nil)
            imageUrl = [NSURL URLWithString:@""];
        
        [[[AGSocialManager shared] pinterest] createPinWithImageURL:imageUrl
                                                           sourceURL:sourceUrl
                                                         description:desc];
        if (block)
            block(nil);
    }
    else
    {
        if (block)
            block([NSError errorWithDomain:@"Pinterest" code:404 userInfo:@{NSLocalizedDescriptionKey : @"You do not have Pinterest App installed, please choose another sharing option.", NSLocalizedRecoverySuggestionErrorKey : @"Choose another option"}]);
    }
*/ 
}
/*

- (void)shareViaGooglePlusWithTitle:(NSString*)title description:(NSString*)desc url:(NSURL*)link thumbnailURL:(NSURL*)turl withCompleteBlock:(void (^)(NSError *))block
{
    self.block = block;
    [appDelegate performSelector:@selector(setUpGoogle)];
    if ([[GPPSignIn sharedInstance] hasAuthInKeychain])
    {
        _infoToShareDict = [NSMutableDictionary dictionary];
        [_infoToShareDict setValue:title forKey:@"title"];
        [_infoToShareDict setValue:desc forKey:@"desc"];
        [_infoToShareDict setValue:link forKey:@"link"];
        [_infoToShareDict setValue:turl forKey:@"turl"];
        [[GPPSignIn sharedInstance] setDelegate:self];
        [[GPPSignIn sharedInstance] trySilentAuthentication];
        [[GPPSignIn sharedInstance] setAttemptSSO:YES];
    }
    else
    {
        [[GPPShare sharedInstance] setDelegate:self];
        id<GPPShareBuilder> shareBuilder = [[GPPShare sharedInstance] shareDialog];
        [shareBuilder setURLToShare:link];
        [shareBuilder setPrefillText:desc];
        [shareBuilder setContentDeepLinkID:[link absoluteString]];
        [shareBuilder setTitle:title
                   description:desc
                  thumbnailURL:turl];
        [shareBuilder open];
    }
}

- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth
                   error:(NSError *)error
{
    NSURL *link = [_infoToShareDict valueForKey:@"link"];
    NSString *desc = [_infoToShareDict valueForKey:@"desc"];
    NSString *title= [_infoToShareDict valueForKey:@"title"];
    NSURL *turl = [_infoToShareDict valueForKey:@"turl"];
    
    [[GPPShare sharedInstance] setDelegate:self];
    id<GPPShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
    
    [shareBuilder setURLToShare:link];
    [shareBuilder setPrefillText:desc];
    [shareBuilder setContentDeepLinkID:[link absoluteString]];
    [shareBuilder setTitle:title
               description:desc
              thumbnailURL:turl];
    if ([shareBuilder open] == NO)
    {
        shareBuilder = [[GPPShare sharedInstance] shareDialog];
        [shareBuilder setURLToShare:link];
        [shareBuilder setPrefillText:desc];
        [shareBuilder setContentDeepLinkID:[link absoluteString]];
        [shareBuilder setTitle:title
                   description:desc
                  thumbnailURL:turl];
        [shareBuilder open];
    }
    _infoToShareDict = nil;
}
*/

@end

/*
@implementation YUMSocialManager (GPPShareDelegate)

- (void)finishedSharingWithError:(NSError *)error
{
    if (self.block)
        self.block(error);
}

- (void)finishedSharing:(BOOL)shared
{
    [[GPPShare sharedInstance] closeActiveNativeShareDialog];
    if (self.block&&shared)
        self.block(nil);
}

@end

*/