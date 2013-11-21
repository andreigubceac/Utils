//
//  AGRestClient.h
//
//  Created by Andrei Gubceac on 11/16/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "BlocksAdditions.h"
#import <Reachability.h>

#define kWebAPIClientSessionExpired @"kWebAPIClientSessionExpired"
#define kServerAPIErrorDomain       @"ServerAPIErrorDomain"
#define kServerAPIErrorDomainNotFoundCode   404


@interface AGRestClient : NSObject
{
    NSString *_accessTokenKey;
}
@property (atomic, readonly) Reachability *reachability;
@property (nonatomic, readonly) NSString *baseURLString;

+ (AGRestClient *)restClientWithBaseURLString:(NSString *)aBaseURLString;
+ (id)sessionToken;
- (void)createNewSessionWithToken:(NSString*)token accountId:(NSString*)aid expiresDate:(NSDate*)date;

- (NSDictionary*)extraHTTPHeaders;
- (BOOL)canAutoLogin;
- (BOOL)isNetworkOK;
- (void)cancelAllInProgressConnections;
- (BOOL)isInProgressConnectionForPath:(NSString*)absoluteString;
- (void)closeSession;

//General
- (NSURLConnection *)doRequestAndParseJSON:(NSMutableURLRequest *)req withSessionId:(BOOL)withSessionId
                              successBlock:(ResultBlock)successBlock errorBlock:(CommunicationErrorBlock)errorBlock completeBlock:(BasicBlock)completeBlock;

//Basic
- (NSURLConnection*)GETJSONRequestWithURLPath:(NSString *)urlPath withSessionId:(BOOL)withSessionId queryParams:(NSDictionary *)queryParams
                                 successBlock:(ResultBlock)successBlock errorBlock:(CommunicationErrorBlock)errorBlock completeBlock:(BasicBlock)completeBlock;

- (NSURLConnection*)POSTJSONRequestWithURLPath:(NSString *)urlPath withSessionId:(BOOL)withSessionId queryParams:(NSDictionary *)queryParams
                                  successBlock:(ResultBlock)successBlock errorBlock:(CommunicationErrorBlock)errorBlock completeBlock:(BasicBlock)completeBlock;

- (NSURLConnection*)PUTJSONRequestWithURLPath:(NSString *)urlPath withSessionId:(BOOL)withSessionId queryParams:(NSDictionary *)queryParams
                                 successBlock:(ResultBlock)successBlock errorBlock:(CommunicationErrorBlock)errorBlock completeBlock:(BasicBlock)completeBlock;

- (NSURLConnection*)PATCHJSONRequestWithURLPath:(NSString *)urlPath withSessionId:(BOOL)withSessionId queryParams:(NSDictionary *)queryParams
                                   successBlock:(ResultBlock)successBlock errorBlock:(CommunicationErrorBlock)errorBlock completeBlock:(BasicBlock)completeBlock;

- (NSURLConnection*)DELETEJSONRequestWithURLPath:(NSString *)urlPath withSessionId:(BOOL)withSessionId
                                    successBlock:(ResultBlock)successBlock errorBlock:(CommunicationErrorBlock)errorBlock completeBlock:(BasicBlock)completeBlock;

- (NSURLConnection*)downloadImageFromPath:(NSString*)path
                             successBlock:(ResultBlock) successBlock errorBlock:(CommunicationErrorBlock)errorBlock completeBlock: (BasicBlock)completeBlock;

- (NSURLConnection*)uploadImageData:(NSData*)imageData imageField:(NSString*)imageField toPath:(NSString*)path params:(NSDictionary*)params
                       successBlock:(ResultBlock) successBlock errorBlock:(CommunicationErrorBlock)errorBlock completeBlock:(BasicBlock)completeBlock;

@end
