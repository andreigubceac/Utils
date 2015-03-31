#import "NSURLConnection+Blocks.h"

@interface NSURLConnectionWithBlocks ()
@property (nonatomic, copy) void(^completeBlock)();
@property (nonatomic, strong) NSMutableData *httpResponseData;
@property (nonatomic, strong) NSHTTPURLResponse *httpResponse;
@property (nonatomic, copy) void(^errorBlock)(NSString *errStr, NSError *err);
@property (nonatomic, copy) void(^successBlock)(NSHTTPURLResponse *httpResponse, NSData *httpResponseData);
@property (nonatomic, copy) void(^httpErrorBlock)(NSInteger code, NSHTTPURLResponse *httpResponse, NSData *httpResponseData);
@property (nonatomic, strong) NSTimer *assynConnectionTimer;
@end
#ifdef DEBUG
#define ULog(...) NSLog(@"%s@%i: %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])
#else
#define ULog(...)
#endif

@implementation NSURLConnectionWithBlocks

- (id)initWithRequest:(NSURLRequest *)request
{
    return [super initWithRequest:request delegate:self startImmediately:NO];
}

- (NSString*)description
{
    return [[super description] stringByAppendingFormat:@" : %@",self.originalRequest];
}

- (void) connection:(NSURLConnection *) connection didReceiveResponse:(NSURLResponse *) aResponse
{
    self.httpResponse = (NSHTTPURLResponse *)aResponse;
    [self.assynConnectionTimer invalidate];
    self.assynConnectionTimer = nil;
//    ULog(@"HTTP response: %@ {status code: %i, headers: %@}",connection.originalRequest, [self.httpResponse statusCode], [self.httpResponse allHeaderFields]);
}

- (void) connection:(NSURLConnection *) connection didReceiveData:(NSData *) data
{
    if (nil == self.httpResponseData)
	{
        self.httpResponseData = [NSMutableData data];
    }
    [self.httpResponseData appendData:data];
}

- (void) connection:(NSURLConnection *) connection didFailWithError:(NSError *) error
{
    ULog(@"connection: %@, error: %@", connection.originalRequest, error);
    [self.assynConnectionTimer invalidate];
    self.assynConnectionTimer = nil;
    self.errorBlock([error localizedDescription], error);
    if (self.completeBlock)
        self.completeBlock(connection);
    self.completeBlock = nil;
    self.successBlock = nil;
}

- (void) connectionDidFinishLoading:(NSURLConnection *) connection
{
    ULog(@"connection finished: %@",connection.originalRequest);
    if ([self.httpResponse statusCode] >= 200 && [self.httpResponse statusCode] < 400)
	{
        if (nil != self.successBlock)
		{
            self.successBlock(self.httpResponse, self.httpResponseData);
        }
    }
    else if (self.httpErrorBlock)
	{
        self.httpErrorBlock([self.httpResponse statusCode], self.httpResponse, self.httpResponseData);
    }

    if (nil != self.completeBlock)
	{
        self.completeBlock(connection);
    }
}

- (void)cancelConnection:(NSTimer*)t{
    NSURLConnection *conn = (NSURLConnection*)[t userInfo];
    [conn cancel];
    [self connection:conn didFailWithError:[NSError errorWithDomain:@"NSURLErrorDomain" code:-1001 userInfo:[NSDictionary dictionaryWithObject:@"The request timed out." forKey:@"NSLocalizedDescription"]]];
    [t invalidate];
}

- (void) dealloc
{
    self.httpResponse = nil;
    self.httpResponseData = nil;
    self.errorBlock = nil;
    self.successBlock = nil;
    self.completeBlock = nil;
    self.httpErrorBlock = nil;
    self.assynConnectionTimer = nil;
}

- (void)start
{
    self.assynConnectionTimer = [NSTimer scheduledTimerWithTimeInterval:self.originalRequest.timeoutInterval target:self selector:@selector(cancelConnection:) userInfo:self repeats:NO];
    [super start];
}

- (void)cancel
{
    [self.assynConnectionTimer invalidate];
    self.assynConnectionTimer = nil;
    [super cancel];
}

- (NSURLConnectionWithBlocks *)connectionCopyWithRequest:(NSURLRequest *)httpRequest
{
    NSURLConnectionWithBlocks *_obj    = [NSURLConnectionWithBlocks connectionWithRequest:httpRequest
                                                                         startImmediately:NO
                                                                             successBlock:self.successBlock
                                                                           httpErrorBlock:self.httpErrorBlock
                                                                               errorBlock:self.errorBlock
                                                                            completeBlock:self.completeBlock];
    _obj.identifier = self.identifier;
    return _obj;
}

+ (NSURLConnectionWithBlocks *) connectionWithRequest:(NSURLRequest *) httpRequest startImmediately:(BOOL) shouldStart
                               successBlock:(void(^)(NSHTTPURLResponse *httpResponse, NSData *httpResponseBodyData))successBlock 
                             httpErrorBlock:(void(^)(NSInteger code, NSHTTPURLResponse *httpResponse, NSData *httpResponseData))httpErrorBlock 
                                 errorBlock:(void(^)(NSString *errStr, NSError *err))errorBlock 
                              completeBlock:(void(^)(NSURLConnection*conn))completeBlock
{
//    ULog(@"HTTP request: {url: %@, method: %@, headers: %@}", [httpRequest URL], [httpRequest HTTPMethod], [httpRequest allHTTPHeaderFields]);
    
    if (![NSURLConnection canHandleRequest:httpRequest]) {
        errorBlock(@"cannot handle request", nil);
        completeBlock(nil);
        return nil;
    }
    NSURLConnectionWithBlocks *connection = [[NSURLConnectionWithBlocks alloc] initWithRequest:httpRequest];
	if (nil == connection) {
        errorBlock(@"could not create connection", nil);
        completeBlock(nil);
        return nil;
    }
    connection.successBlock = successBlock;
    connection.errorBlock = errorBlock;
    connection.completeBlock = completeBlock;
    connection.httpErrorBlock = httpErrorBlock;
	if (shouldStart)
        [connection start];
    return connection;
}

@end
