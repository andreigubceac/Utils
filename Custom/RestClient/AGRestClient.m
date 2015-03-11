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

@interface  AGRestClient()
{
    NSMutableDictionary *_connectionInProgress, *_connectionsInPendding, *_connectionsToRebuild;
}
@end

#ifdef DEBUG
#define AGLog(...) NSLog(@"%s@%i: %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])
#else
#define AGLog(...)
#endif

@implementation AGRestClient

+ (AGRestClient *)restClientWithBaseURLString:(NSString *)aBaseURLString
{
    return [[[self class] alloc] initWithBaseUrlString:aBaseURLString];
}

#pragma mark - overrided
static int maxConnectionInprogress = 10;

+ (id)sessionToken
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"AGWebClientSession"] valueForKey:@"auth_token"];
}

- (id)initWithBaseUrlString:(NSString*)baseUrlString
{
    if ((self = [super init]))
    {
        _baseURLString          = baseUrlString;
        _accessTokenKey         = @"auth_token";
        _accessTokenValue       = [[self class] sessionToken];
        _connectionInProgress   = [[NSMutableDictionary alloc] init];
        _connectionsInPendding  = [[NSMutableDictionary alloc] init];
        _connectionsToRebuild   = [[NSMutableDictionary alloc] init];
        _reachability           = [Reachability reachabilityForInternetConnection];
        [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
    }
    return self;
}

- (id)init
{
    return [self initWithBaseUrlString:@"http://localhost:8080"];
}

- (BOOL)isNetworkOK
{
    return [_reachability isReachable];
}

- (BOOL)canAutoLogin
{
    return [[[self class] sessionToken]length]>0;
}

- (void)cancelAllInProgressConnections
{
    [[_connectionInProgress allValues] makeObjectsPerformSelector:@selector(cancel) withObject:nil];
    [_connectionInProgress removeAllObjects];
    [[_connectionsInPendding allValues] makeObjectsPerformSelector:@selector(cancel) withObject:nil];
    [_connectionsInPendding removeAllObjects];
    [_connectionsToRebuild removeAllObjects];
}

- (void)cancelConneciton:(NSURLConnectionWithBlocks*)conn
{
    [conn cancel];
    if (conn.identifier)
    {
        [_connectionInProgress removeObjectForKey:conn.identifier];
        [_connectionsInPendding removeObjectForKey:conn.identifier];
        [_connectionsToRebuild removeObjectForKey:conn.identifier];
    }
}

- (void)closeSession
{
    [self cancelAllInProgressConnections];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AGWebClientSession"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _accessTokenValue = nil;
}

- (BOOL)isInProgressConnectionForPath:(NSString*)absoluteString
{
    NSString *_connectionKey = [absoluteString copy];
    return ([_connectionInProgress objectForKey:_connectionKey] || [_connectionsInPendding objectForKey:_connectionKey]);
}

#pragma mark - private

- (void)createNewSessionWithToken:(NSString*)token
{
    [[NSUserDefaults standardUserDefaults] setObject:@{@"auth_token" : (_accessTokenValue = [NSString emptyString:token])} forKey:@"AGWebClientSession"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary*)extraHTTPHeaders
{
    return nil;
}

- (void)buildUrlFromRequest:(NSMutableURLRequest*)req withSessionId:(BOOL)withSessionId
{
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
    
    if (withSessionId && _accessTokenValue.length)
    {
        if ([queryParams.lastObject rangeOfString:_accessTokenKey].location != NSNotFound)
            [queryParams removeLastObject];
        [queryParams addObject:[NSString stringWithFormat:@"%@=%@", _accessTokenKey, _accessTokenValue]];
    }
    
    sessionURLStr = [NSString stringWithFormat:@"%@%@%@", sessionURLStr,([queryParams count]?@"?":@""), [queryParams componentsJoinedByString:@"&"]];
    NSURL *sessionURL = [NSURL URLWithString:sessionURLStr];
    req.URL = sessionURL;
    NSDictionary *_extra = [self extraHTTPHeaders];
    if ([_extra isKindOfClass:[NSDictionary class]])
    {
        for (id _key in _extra.allKeys)
            [req setValue:_extra[_key] forHTTPHeaderField:_key];
    }
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
    [self buildUrlFromRequest:req withSessionId:withSessionId];
    //    WCLog(@"doRequest: %@", sessionURL);
    NSURLConnectionWithBlocks *connection = nil;
    connection = [NSURLConnectionWithBlocks connectionWithRequest:req startImmediately:NO
                                                     successBlock:^(NSHTTPURLResponse *res, NSData *resBody){
                                                         successBlock(resBody);
                                                     }
                                                   httpErrorBlock:^(NSInteger code, NSHTTPURLResponse *res, NSData *resBody){
                                                       errorBlock(code,[NSError errorWithDomain:kServerAPIErrorDomain code:code
                                                                                       userInfo:@{NSLocalizedDescriptionKey : [[NSString alloc] initWithData:resBody encoding:NSUTF8StringEncoding]}]);
                                                   }
                                                       errorBlock:^(NSString *errStr, NSError *err) { errorBlock([err code],err); }
                                                    completeBlock:^(NSURLConnection*_connection){
                                                        [_connectionInProgress removeObjectForKey:_connectionKey];
                                                        if (_accessTokenValue.length)
                                                        {
                                                            [[NSURLCache sharedURLCache] removeCachedResponseForRequest:req];
                                                            for (id _key in _connectionsToRebuild.allKeys)
                                                            {
                                                                NSURLConnectionWithBlocks *_conn = [_connectionsToRebuild valueForKey:_key];
                                                                NSMutableURLRequest *_req = [NSMutableURLRequest requestWithURL:_conn.originalRequest.URL];
                                                                [self buildUrlFromRequest:_req withSessionId:YES];
                                                                _conn = [_conn connectionCopyWithRequest:_req];
                                                                [_connectionsInPendding setValue:_conn forKey:_conn.identifier];
                                                            }
                                                            if (_connectionsToRebuild.count)
                                                                [_connectionsToRebuild removeAllObjects];
                                                        }
                                                        else if (_accessTokenValue && _accessTokenValue.length == 0)
                                                            [_connectionsToRebuild setValue:_connection forKey:_connectionKey];
                                                        if ([_connectionInProgress allValues].count == 0 && _accessTokenValue.length)
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
            AGLog(@"Start urlconnection : %@ : %@ : %@",connection.originalRequest, connection.originalRequest.HTTPMethod,_body);
#endif
        }
        else
            [_connectionsInPendding setValue:connection forKey:_connectionKey];
    }
    return connection;
}

- (NSURLConnection *)doJSONRequest:(NSMutableURLRequest *)req withSessionId:(BOOL)withSessionId
                      successBlock:(ResultBlock)successBlock errorBlock:(CommunicationErrorBlock)errorBlock completeBlock:(BasicBlock)completeBlock {
    
    [req setValue:@"application/json; charset=utf-16" forHTTPHeaderField:@"Content-Type"];
    return [self doRequestAndParseJSON:req withSessionId:withSessionId successBlock:successBlock errorBlock:errorBlock completeBlock:completeBlock];
}

- (NSURLConnection *)doRequestAndParseJSON:(NSMutableURLRequest *)req withSessionId:(BOOL)withSessionId
                              successBlock:(ResultBlock)successBlock errorBlock:(CommunicationErrorBlock)errorBlock completeBlock:(BasicBlock)completeBlock {
	return [self doRequest:req withSessionId:withSessionId successBlock:^(id resBody) {
        NSError *jsonError = nil;
        id res = [NSJSONSerialization JSONObjectWithData:resBody options:NSJSONReadingAllowFragments error:&jsonError];
        if (nil != res) {
            AGLog(@"%@", res);
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
        AGLog(@"%@",errObj);
        errorBlock(code,errObj);
    } completeBlock:completeBlock];
}


- (NSURLConnection*)GETJSONRequestWithURLPath:(NSString *)urlPath withSessionId:(BOOL)withSessionId queryParams:(NSDictionary *)queryParams
                                 successBlock:(ResultBlock)successBlock errorBlock:(CommunicationErrorBlock)errorBlock completeBlock:(BasicBlock)completeBlock
{
    NSMutableString *urlStr = [NSMutableString stringWithFormat:@"%@/%@?", self.baseURLString, urlPath];
    for (id _pName in [queryParams allKeys])
        [urlStr appendFormat:@"%@=%@&",_pName, [queryParams[_pName] URLEncodedString]];
    [urlStr deleteCharactersInRange:NSMakeRange(urlStr.length-1, 1)];
    return [self doJSONRequest:[NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]] withSessionId:withSessionId successBlock:successBlock errorBlock:errorBlock completeBlock:completeBlock];
}

- (NSURLConnection*)POSTJSONRequestWithURLPath:(NSString *)urlPath withSessionId:(BOOL)withSessionId queryParams:(NSDictionary *)queryParams
                                  successBlock:(ResultBlock)successBlock errorBlock:(CommunicationErrorBlock)errorBlock completeBlock:(BasicBlock)completeBlock
{
    NSMutableURLRequest *_req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",self.baseURLString,urlPath]]];
    [_req setHTTPMethod:@"POST"];
    if (queryParams)
        [_req setHTTPBody:[NSJSONSerialization dataWithJSONObject:queryParams options:NSJSONWritingPrettyPrinted error:nil]];
    return [self doJSONRequest:_req withSessionId:withSessionId successBlock:successBlock errorBlock:errorBlock completeBlock:completeBlock];
}

- (NSURLConnection*)PUTJSONRequestWithURLPath:(NSString *)urlPath withSessionId:(BOOL)withSessionId queryParams:(NSDictionary *)queryParams
                                 successBlock:(ResultBlock)successBlock errorBlock:(CommunicationErrorBlock)errorBlock completeBlock:(BasicBlock)completeBlock
{
    NSMutableURLRequest *_req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",self.baseURLString,urlPath]]];
    [_req setHTTPMethod:@"PUT"];
    if (queryParams)
        [_req setHTTPBody:[NSJSONSerialization dataWithJSONObject:queryParams options:NSJSONWritingPrettyPrinted error:nil]];
    return [self doJSONRequest:_req withSessionId:withSessionId successBlock:successBlock errorBlock:errorBlock completeBlock:completeBlock];
}

- (NSURLConnection*)PATCHJSONRequestWithURLPath:(NSString *)urlPath withSessionId:(BOOL)withSessionId queryParams:(NSDictionary *)queryParams
                                   successBlock:(ResultBlock)successBlock errorBlock:(CommunicationErrorBlock)errorBlock completeBlock:(BasicBlock)completeBlock
{
    NSMutableURLRequest *_req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",self.baseURLString,urlPath]]];
    [_req setHTTPMethod:@"PATCH"];
    if (queryParams)
        [_req setHTTPBody:[NSJSONSerialization dataWithJSONObject:[queryParams dictionaryWithNullValuesRemoved] options:NSJSONWritingPrettyPrinted error:nil]];
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
    
    for (NSString *_key in [params allKeys])
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
