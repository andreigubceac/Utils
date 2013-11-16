//
//  AGRestClient.m
//
//  Created by Andrei Gubceac on 11/16/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "AGRestClient.h"

#import "NSURLConnection+Blocks.h"
#import "NSDictionary+Additions.h"
#import "NSString+Additions.h"


@interface AGSession : NSObject;
@property (atomic, readonly) NSString *auth_token, *user_id;
@property (atomic, readonly) NSDate *expires;
@property (nonatomic, strong) NSTimer *expiresTimer;

- (id)initWithToken:(NSString*)token withAccountId:(NSString*)aid withExpiresDate:(NSDate*)edate;
- (id)initWithDictionary:(id)sessionDictionary;
- (void)closeAndClearTokenInformation;
- (BOOL)canAutoLogin;//user_id>0 && session expired = NO
- (BOOL)isSessionValid;
@end


@implementation AGSession

- (id)initWithToken:(NSString*)token withAccountId:(NSString*)aid withExpiresDate:(NSDate*)edate
{
    self = [super init];
    if (self)
    {
        _auth_token = token;
        _user_id = aid;
        _expires    = edate;
        
        [[NSUserDefaults standardUserDefaults] setObject:@{@"auth_token" : token?token:@"", @"user_id": aid?aid:@"", @"expires" : edate?edate:[NSDate dateWithTimeIntervalSince1970:0]} forKey:@"AGWebClientSession"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if ([[NSDate date] compare:edate] == NSOrderedAscending)
            self.expiresTimer = [[NSTimer alloc] initWithFireDate:edate interval:0 target:self selector:@selector(expiresTimerAction:) userInfo:nil repeats:NO];
        
    }
    return self;
}

- (id)initWithDictionary:(id)sessionDictionary
{
    return [self initWithToken:sessionDictionary[@"auth_token"] withAccountId:sessionDictionary[@"user_id"] withExpiresDate:[NSDate dateWithTimeIntervalSince1970:[sessionDictionary[@"expires"] doubleValue]]];
}

- (id)init
{
    id _session = [[NSUserDefaults standardUserDefaults] objectForKey:@"AGWebClientSession"];
    return [self initWithToken:[_session valueForKey:@"auth_token"] withAccountId:_session[@"user_id"] withExpiresDate:_session[@"expires"]];
}

- (NSString*)description
{
    return [[super description] stringByAppendingFormat:@" %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"AGWebClientSession"]];
}

- (void)dealloc
{
    _expires = nil;
    _auth_token = nil;
    _user_id = nil;
    [self.expiresTimer invalidate];
    self.expiresTimer = nil;
}

- (void)closeAndClearTokenInformation
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AGWebClientSession"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _expires = nil;
    _auth_token = nil;
    _user_id = nil;
    [self.expiresTimer invalidate];
    self.expiresTimer = nil;
}

- (void)expiresTimerAction:(NSTimer*)t
{
    [t invalidate];
    [[NSNotificationCenter defaultCenter] postNotificationName:kWebAPIClientSessionExpired object:nil];
    self.expiresTimer = nil;
}

- (BOOL)isSessionValid
{
    return (_expires != nil);// && [_expires compare:[NSDate dateWithTimeIntervalSinceNow:600]] == NSOrderedDescending);
}

- (BOOL)canAutoLogin
{
    return ([_user_id intValue] > 0 && [self isSessionValid]);
}
@end


@interface  AGRestClient()
{
    NSMutableDictionary *_connectionInProgress, *_connectionsInPendding;
}
@property (atomic, readonly) AGSession *session;
@end


@implementation AGRestClient

+ (AGRestClient *)restClientWithBaseURLString:(NSString *)aBaseURLString
{
    AGRestClient *webClient = [[[self class] alloc] init];
    [webClient setBaseURLString:aBaseURLString];
    return webClient;
}

#pragma mark - overrided
static int maxConnectionInprogress = 10;

+ (id)sessionToken
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"DMWebClientSession"] valueForKey:@"auth_token"];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _connectionInProgress   = [[NSMutableDictionary alloc] init];
        _connectionsInPendding  = [[NSMutableDictionary alloc] init];
        _session = [[AGSession alloc] init];
        [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
    }
    return self;
}

- (void)dealloc
{
    [_reachability stopNotifier];
}

- (void)setBaseURLString:(NSString *)baseURLString_
{
    _baseURLString = baseURLString_;
    if (baseURLString_)
    {
        _reachability = [Reachability reachabilityForInternetConnection];
    }
}

- (BOOL)isNetworkOK
{
    return [_reachability isReachable];
    if ([_reachability isReachableViaWiFi])
        return YES;
    else if ([_reachability isReachableViaWWAN])
        return YES;
    return NO;
}

- (BOOL)canAutoLogin
{
    return [_session canAutoLogin];
}

- (void)cancelAllInProgressConnections
{
    [[_connectionInProgress allValues] makeObjectsPerformSelector:@selector(cancel) withObject:nil];
    [_connectionInProgress removeAllObjects];
    [[_connectionsInPendding allValues] makeObjectsPerformSelector:@selector(cancel) withObject:nil];
    [_connectionsInPendding removeAllObjects];
}

- (void)closeSession
{
    [_session closeAndClearTokenInformation];
    _session = nil;
}

- (BOOL)isInProgressConnectionForPath:(NSString*)absoluteString
{
    NSString *_connectionKey = [absoluteString copy];
    return ([_connectionInProgress objectForKey:_connectionKey] || [_connectionsInPendding objectForKey:_connectionKey]);
}

#pragma mark - private

- (void)createNewSessionWithToken:(NSString*)token accountId:(NSString*)aid expiresDate:(NSDate*)date
{
    [_session closeAndClearTokenInformation];
    _session = [[AGSession alloc] initWithToken:token
                                  withAccountId:aid
                                withExpiresDate:date];
}


- (NSURLConnection *)doRequest:(NSMutableURLRequest *)req withSessionId:(BOOL)withSessionId
                  successBlock:(ResultBlock)successBlock errorBlock:(CommunicationErrorBlock)errorBlock completeBlock:(BasicBlock)completeBlock
{
    if ([self isNetworkOK] == NO)
    {
        errorBlock(-1009,[NSError errorWithDomain:NSURLErrorDomain code:-1009 userInfo:@{NSLocalizedDescriptionKey : @"The Internet connection appears to be offline."}]);
        if (completeBlock)
            completeBlock();
        return nil;
    }
    NSString *_connectionKey = [[[req URL] absoluteString] copy];
    if ([self isInProgressConnectionForPath:_connectionKey])
    {
        errorBlock(500,nil);//[NSError errorWithDomain:NSURLErrorDomain code:500 userInfo:@{NSLocalizedDescriptionKey : @"Duplicate request"}]);
        if (completeBlock)
            completeBlock();
        return nil;
    }
    NSURL *url = [req URL];
    NSString *pathPart = [url path];
    if ([@"" isEqualToString:pathPart]) {
        pathPart = @"/";
    }
    else
    {
        NSString *_lastPathComp = [pathPart lastPathComponent];
        pathPart = [[pathPart stringByDeletingLastPathComponent] stringByAppendingPathComponent:[_lastPathComp URLEncodedString]];
    }
    NSString *portPart = [url port] ? [NSString stringWithFormat:@":%i", [[url port] intValue]] : @"";
    NSString *sessionURLStr = [NSString stringWithFormat:@"%@://%@%@%@", [url scheme], [url host], portPart, pathPart];
    NSMutableArray *queryParams = [[[url query] componentsSeparatedByString:@"&"] mutableCopy];
    if (nil == queryParams)
        queryParams = [NSMutableArray array];
    
    if (withSessionId)
    {
        //        [queryParams addObject:[NSString stringWithFormat:@"cKey=%@", [NSString getUUID]]];
        [queryParams addObject:[NSString stringWithFormat:@"%@=%@", @"auth_token", self.session.auth_token]];
    }
    
    sessionURLStr = [NSString stringWithFormat:@"%@%@%@", sessionURLStr,([queryParams count]?@"?":@""), [queryParams componentsJoinedByString:@"&"]];
    NSURL *sessionURL = [NSURL URLWithString:sessionURLStr];
    req.URL = sessionURL;
    //    WCLog(@"doRequest: %@", sessionURL);
    __block NSURLConnectionWithBlocks *connection = nil;
    connection = [NSURLConnectionWithBlocks connectionWithRequest:req startImmediately:NO
                                                     successBlock:^(NSHTTPURLResponse *res, NSData *resBody){
                                                         successBlock(resBody);
                                                     }
                                                   httpErrorBlock:^(NSInteger code, NSHTTPURLResponse *res, NSData *resBody){
                                                       errorBlock(code,[NSError errorWithDomain:kServerAPIErrorDomain code:code
                                                                                       userInfo:@{NSLocalizedDescriptionKey : [[NSString alloc] initWithData:resBody encoding:NSUTF8StringEncoding]}]);
                                                       if (401 == code)
                                                       {
                                                           [[NSNotificationCenter defaultCenter] postNotificationName:kWebAPIClientSessionExpired object:nil];
                                                       }
                                                   }
                                                       errorBlock:^(NSString *errStr, NSError *err) { errorBlock([err code],err); }
                                                    completeBlock:^(NSURLConnection*_connection){
                                                        [_connectionInProgress removeObjectForKey:_connectionKey];
                                                        if ([_connectionInProgress allValues].count == 0)
                                                        {
                                                            for (unsigned i=0;i<maxConnectionInprogress&&i<[[_connectionsInPendding allValues] count];i++)
                                                            {
                                                                NSURLConnectionWithBlocks *conn = [[_connectionsInPendding allValues] objectAtIndex:i];
                                                                [_connectionInProgress setValue:conn forKey:conn.identifier];
                                                                [_connectionsInPendding removeObjectForKey:conn.identifier];
                                                                [conn start];
                                                            }
                                                        }
                                                        if (completeBlock) completeBlock();
                                                    }];
    if (connection)
    {
        connection.identifier = _connectionKey;
        if ([_connectionInProgress allValues].count < maxConnectionInprogress)
        {
            [_connectionInProgress setValue:connection forKey:_connectionKey];
            [connection start];
#if DEBUG
            NSString *_body = nil;
            _body = [[NSString alloc] initWithData: connection.originalRequest.HTTPBody encoding:NSUTF8StringEncoding];
            DLog(@"Start urlconnection : %@ : %@ : %@",connection.originalRequest, connection.originalRequest.HTTPMethod,_body);
#endif
        }
        else
            [_connectionsInPendding setValue:connection forKey:_connectionKey];
    }
    return connection;
}

- (NSURLConnection *)doJSONRequest:(NSMutableURLRequest *)req withSessionId:(BOOL)withSessionId
                      successBlock:(ResultBlock)successBlock errorBlock:(CommunicationErrorBlock)errorBlock completeBlock:(BasicBlock)completeBlock {
    
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    return [self doRequestAndParseJSON:req withSessionId:withSessionId successBlock:successBlock errorBlock:errorBlock completeBlock:completeBlock];
}

- (NSURLConnection *)doRequestAndParseJSON:(NSMutableURLRequest *)req withSessionId:(BOOL)withSessionId
                              successBlock:(ResultBlock)successBlock errorBlock:(CommunicationErrorBlock)errorBlock completeBlock:(BasicBlock)completeBlock {
	return [self doRequest:req withSessionId:withSessionId successBlock:^(id resBody) {
        NSError *jsonError = nil;
        id res = [NSJSONSerialization JSONObjectWithData:resBody options:NSJSONReadingAllowFragments error:&jsonError];
        if (nil != res) {
            DLog(@"resStr: %@", res);
            successBlock(res);
            /*
             NSString *serverOk = [res valueForKey:@"result"];
             if ([serverOk isEqualToString:@"success"]) {
             successBlock(res);
             return;
             }
             NSString *errMessage = [[res valueForKey:@"error"] valueForKey:@"message"];
             NSInteger errCode = [[[res valueForKey:@"error"] valueForKey:@"code"] integerValue];
             errorBlock(errCode, [NSError errorWithDomain:kServerAPIErrorDomain code:errCode userInfo:@{NSLocalizedDescriptionKey : errMessage, NSLocalizedFailureReasonErrorKey : [[res valueForKey:@"error"] valueForKey:@"detailmsg"]}]);
             */
        }
        else
            errorBlock([jsonError code], jsonError );
    } errorBlock:^(NSInteger code, id errObj){
        DLog(@"%@",errObj);
        errorBlock(code,errObj);
    } completeBlock:completeBlock];
}


- (NSURLConnection*)GETJSONRequestWithURLPath:(NSString *)urlPath withSessionId:(BOOL)withSessionId queryParams:(NSDictionary *)queryParams
                                 successBlock:(ResultBlock)successBlock errorBlock:(CommunicationErrorBlock)errorBlock completeBlock:(BasicBlock)completeBlock
{
    NSMutableString *urlStr = [NSMutableString stringWithFormat:@"%@/%@?", self.baseURLString, urlPath];
    for (id _pName in [queryParams allKeys])
        [urlStr appendFormat:@"%@=%@&",_pName, [queryParams[_pName] URLEncodedString]];
    return [self doJSONRequest:[NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]] withSessionId:withSessionId successBlock:successBlock errorBlock:errorBlock completeBlock:completeBlock];
}

- (NSURLConnection*)POSTJSONRequestWithURLPath:(NSString *)urlPath withSessionId:(BOOL)withSessionId queryParams:(NSDictionary *)queryParams
                                  successBlock:(ResultBlock)successBlock errorBlock:(CommunicationErrorBlock)errorBlock completeBlock:(BasicBlock)completeBlock
{
    NSMutableURLRequest *_req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",self.baseURLString,urlPath]]];
    [_req setHTTPMethod:@"POST"];
    if (queryParams)
        [_req setHTTPBody:[NSJSONSerialization dataWithJSONObject:queryParams options:NSJSONReadingAllowFragments error:nil]];
    return [self doJSONRequest:_req withSessionId:withSessionId successBlock:successBlock errorBlock:errorBlock completeBlock:completeBlock];
}

- (NSURLConnection*)PUTJSONRequestWithURLPath:(NSString *)urlPath withSessionId:(BOOL)withSessionId queryParams:(NSDictionary *)queryParams
                                 successBlock:(ResultBlock)successBlock errorBlock:(CommunicationErrorBlock)errorBlock completeBlock:(BasicBlock)completeBlock
{
    NSMutableURLRequest *_req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",self.baseURLString,urlPath]]];
    [_req setHTTPMethod:@"PUT"];
    if (queryParams)
        [_req setHTTPBody:[NSJSONSerialization dataWithJSONObject:queryParams options:NSJSONReadingAllowFragments error:nil]];
    return [self doJSONRequest:_req withSessionId:withSessionId successBlock:successBlock errorBlock:errorBlock completeBlock:completeBlock];
}

- (NSURLConnection*)PATCHJSONRequestWithURLPath:(NSString *)urlPath withSessionId:(BOOL)withSessionId queryParams:(NSDictionary *)queryParams
                                   successBlock:(ResultBlock)successBlock errorBlock:(CommunicationErrorBlock)errorBlock completeBlock:(BasicBlock)completeBlock
{
    NSMutableURLRequest *_req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",self.baseURLString,urlPath]]];
    [_req setHTTPMethod:@"PATCH"];
    if (queryParams)
        [_req setHTTPBody:[NSJSONSerialization dataWithJSONObject:[queryParams dictionaryWithNullValuesRemoved] options:NSJSONReadingAllowFragments error:nil]];
    return [self doJSONRequest:_req withSessionId:withSessionId successBlock:successBlock errorBlock:errorBlock completeBlock:completeBlock];
}

- (NSURLConnection*)DELETEJSONRequestWithURLPath:(NSString *)urlPath withSessionId:(BOOL)withSessionId
                                    successBlock:(ResultBlock)successBlock errorBlock:(CommunicationErrorBlock)errorBlock completeBlock:(BasicBlock)completeBlock
{
    NSMutableURLRequest *_req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",self.baseURLString,urlPath]]];
    [_req setHTTPMethod:@"DELETE"];
    return [self doJSONRequest:_req withSessionId:withSessionId successBlock:successBlock errorBlock:errorBlock completeBlock:completeBlock];
}

- (NSURLConnection*)downloadImageFromPath:(NSString*)path
                             successBlock:(ResultBlock) successBlock errorBlock:(CommunicationErrorBlock)errorBlock completeBlock: (BasicBlock)completeBlock
{
    NSMutableURLRequest *_req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    return [self doRequest:_req withSessionId:NO successBlock:successBlock errorBlock:errorBlock completeBlock:completeBlock];
}

- (NSURLConnection*)uploadImageData:(NSData*)imageData imageField:(NSString*)imageField toPath:(NSString*)path params:(NSDictionary*)params
                       successBlock:(ResultBlock) successBlock errorBlock:(CommunicationErrorBlock)errorBlock completeBlock:(BasicBlock)completeBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    [request setHTTPMethod:@"POST"];
    
    
    NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    NSString *boundary = @"0xKhTmLbOuNdArY";
    NSString *endBoundary = [NSString stringWithFormat:@"\r\n--%@\r\n", boundary];
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; charset=%@; boundary=%@", charset, boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    
    NSMutableData *tempPostData = [NSMutableData data];
    [tempPostData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    for (NSString *_key in params)
    {
        [tempPostData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", _key] dataUsingEncoding:NSUTF8StringEncoding]];
        [tempPostData appendData:[[params valueForKey:_key] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [tempPostData appendData:[endBoundary dataUsingEncoding:NSUTF8StringEncoding]];
    
    [tempPostData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", imageField, @"uploaded_file_name.jpg"] dataUsingEncoding:NSUTF8StringEncoding]];
    [tempPostData appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [tempPostData appendData:imageData];
    [tempPostData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:tempPostData];
    
    return [self doRequestAndParseJSON:request withSessionId:YES successBlock:successBlock errorBlock:errorBlock completeBlock:completeBlock];
}

@end
