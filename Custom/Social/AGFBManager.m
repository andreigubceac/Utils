//
//  AGFBManager.m
//
//  Created by Andrei Gubceac on 10/25/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "AGFBManager.h"

@interface AGFBManager ()
{
}
@end

@implementation AGFBManager
@synthesize me = _me;

- (id)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

#pragma mark - public

- (BOOL)isLogged
{
    return [[FBSession activeSession] isOpen];
}

- (NSString*)accessToken
{
    if ([FBSession activeSession].state == FBSessionStateOpen)
        return [FBSession activeSession].accessTokenData.accessToken;
    return nil;
}

- (BOOL)handleOpenURL:(NSURL*)url
{
    return [FBSession.activeSession handleOpenURL:url];
}

- (void)logout
{
    _me = nil;
    [[FBSession activeSession] closeAndClearTokenInformation];
}

-(void)renewFacebookCredentials{
	[[FBSession activeSession] closeAndClearTokenInformation];
	[FBSession renewSystemCredentials:^(ACAccountCredentialRenewResult result, NSError *error) {
		[FBSession openActiveSessionWithReadPermissions:@[@"email"] allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
			
		}];
	}];
}


-(void)fbResyncWithCompleteBlock:(void(^)(NSError*))cblock
{
	[[FBSession activeSession] closeAndClearTokenInformation];
	
    ACAccountStore *accountStore;
    ACAccountType *accountTypeFB;
    if ((accountStore = [[ACAccountStore alloc] init]) && (accountTypeFB = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook] ) )
    {
        
        NSArray *fbAccounts = [accountStore accountsWithAccountType:accountTypeFB];
        id account;
        if (fbAccounts && [fbAccounts count] > 0 && (account = [fbAccounts objectAtIndex:0])){
            
            [accountStore renewCredentialsForAccount:account completion:^(ACAccountCredentialRenewResult renewResult, NSError *error) {
                //we don't actually need to inspect renewResult or error.
                if (cblock)
                {
                    OnMainThread(NO, ^{
                        cblock(error);
                    });
                }
            }];
			
        }
        else if (cblock)
            cblock(nil);
    }
	else if (cblock)
        cblock(nil);
}


- (void)authorizeToGetInfoAboutMeWithCompleteBlock:(void(^)(id<FBGraphUser>, NSError*))cblock
{
    if ([[FBSession activeSession] isOpen])
    {
        if (_me == nil)
        {
            [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (error == nil)
                {
                    _me = result;
                    if (cblock)
                        cblock(result,nil);
                }
            }];
        }
        else if (cblock)
            cblock(_me,nil);
    }
    else
    {
        if (![FBSession openActiveSessionWithReadPermissions:@[@"email"] allowLoginUI:NO completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
			
			[self authorizeToGetInfoAboutMeWithCompleteBlock:cblock];
            
		}])
			
            [FBSession openActiveSessionWithReadPermissions:@[@"email"] allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                switch (status) {
                    case FBSessionStateOpen:
                    case FBSessionStateOpenTokenExtended:[self authorizeToGetInfoAboutMeWithCompleteBlock:cblock];
                        break;
                    case FBSessionStateCreatedOpening:[[FBSession activeSession] handleDidBecomeActive];
                        break;
                    case FBSessionStateClosed:
                        if (cblock)
                            cblock(nil, error);
                        break;
                    case FBSessionStateClosedLoginFailed:
                    {
                        if(error)
                        {
                            [self fbResyncWithCompleteBlock:^(NSError *resyncError)
                             {
                                 cblock(nil,resyncError?resyncError:error);
                             }];
                        }
                        else if (cblock)
                            cblock(nil,nil);
                        [NSThread sleepForTimeInterval:0.5];
                    }
                        break;
                    default:
                        break;
                }
            }];
    }
}

//- (void)postMessage:(NSString*)msg withPhoto:(UIImage*)photo photolink:(NSString*)plink url:(NSString*)url withCompletBlock:(void(^)(NSError*))cblock
- (void)shareFeedWithDictionary:(id)pd withCompletBlock:(void(^)(NSError*))cblock
{
    if ([[FBSession activeSession] isOpen])
    {
        //		if (photo) {
        //			//Image post flow. First upload the photo and then make a new post.
        //			[FBRequestConnection startWithGraphPath:@"me/photos"
        //										 parameters:@{@"source": photo, @"message" : msg, @"link" : url}
        //										 HTTPMethod:@"POST"
        //								  completionHandler:^(FBRequestConnection *connection, FBGraphObject *result, NSError *error)
        //			 {
        //                     if (cblock)
        //                         cblock(error);
        //			 }];
        //		}
        //		else {
        void (^shareBlock)();
        FBShareDialogParams *_sdp = [[FBShareDialogParams alloc] init];
        _sdp.caption= pd[@"caption"];
        _sdp.link   = [NSURL URLWithString:pd[@"link"]];
        _sdp.picture= [NSURL URLWithString:pd[@"picture"]];
        _sdp.description = pd[@"description"];
        _sdp.name   = pd[@"name"];
        
        if ([FBDialogs canPresentShareDialogWithParams:_sdp])
        {
            shareBlock = ^()
            {
                [FBDialogs presentShareDialogWithParams:_sdp clientState:nil
                                                handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                    if (cblock)
                                                        cblock(error);
                                                }];
            };
        }
        else
        {
            shareBlock = ^(){
                [FBRequestConnection startWithGraphPath:@"me/feed"
                                             parameters:pd
                                             HTTPMethod:@"POST"
                                      completionHandler:^(FBRequestConnection *connection, id result, NSError *error)
                 {
                     if (cblock)
                         cblock(error);
                 }];
            };
        }
        
        if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
            // if we don't already have the permission, then we request it now
            [FBSession.activeSession requestNewPublishPermissions:@[@"publish_actions"]
                                                  defaultAudience:FBSessionDefaultAudienceFriends
                                                completionHandler:^(FBSession *session, NSError *error) {
                                                    shareBlock();
                                                }];
        }
        else
        {
            shareBlock();
        }
        
    }
    else
    {
        [self authorizeToGetInfoAboutMeWithCompleteBlock:^(id<FBGraphUser>user,NSError*err) {
            if (user)
                [self shareFeedWithDictionary:pd withCompletBlock:cblock];
        }];
    }
}

- (void)sendAppRequestTo:(NSArray*)profile_ids message:(NSString*)message withCompletBlock:(void(^)(bool, NSError*))cblock
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:message,  @"message",nil];
    
    switch (profile_ids.count) {
        case 0:
            break;
        case 1:
            [params setValue:[profile_ids lastObject][@"id"] forKey:@"to"];
            break;
        default:
			
			NSLog(@"Sending Request to: %@", profile_ids);
			
			NSString * paramString = [[NSMutableString alloc] init];
			
			for (NSDictionary * obj in profile_ids)
				paramString = [paramString stringByAppendingString:[NSString stringWithFormat:@"%@,", obj[@"id"]]];
			
			
			[params setValue:paramString forKey:@"to"];
			
			break;
    }
    [FBWebDialogs presentDialogModallyWithSession:nil dialog:@"apprequests" parameters:params handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
		
		if (error && cblock)
			cblock(NO, error);
		else if (result == FBWebDialogResultDialogCompleted)
			cblock(YES, nil);
		
    }];
    
}
@end
