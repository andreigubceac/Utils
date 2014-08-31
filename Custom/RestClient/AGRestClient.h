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

@class NSURLConnectionWithBlocks;

@interface AGRestClient : NSObject
{
    NSString *_accessTokenKey, *_accessTokenValue;
}
@property (atomic, readonly) Reachability *reachability;
@property (nonatomic, strong) NSString *baseURLString;

+ (AGRestClient *)restClientWithBaseURLString:(NSString *)aBaseURLString;
+ (id)sessionToken;

- (id)initWithBaseUrlString:(NSString*)baseUrlString;
- (void)createNewSessionWithToken:(NSString*)token;

- (NSDictionary*)extraHTTPHeaders;
- (BOOL)canAutoLogin;
- (BOOL)isNetworkOK;
- (void)cancelAllInProgressConnections;
- (void)cancelConneciton:(NSURLConnectionWithBlocks*)conn;
- (BOOL)isInProgressConnectionForPath:(NSString*)absoluteString;
- (void)closeSession;

//General
- (NSURLConnection *)doRequest:(NSMutableURLRequest *)req withSessionId:(BOOL)withSessionId
                  successBlock:(ResultBlock)successBlock errorBlock:(CommunicationErrorBlock)errorBlock completeBlock:(BasicBlock)completeBlock;

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
