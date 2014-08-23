#import <Foundation/Foundation.h>

@interface NSURLConnectionWithBlocks: NSURLConnection
@property (nonatomic, copy) NSString* identifier;

+ (NSURLConnectionWithBlocks *)connectionWithRequest:(NSURLRequest *)httpRequest startImmediately:(BOOL)shouldStart successBlock:(void(^)(NSHTTPURLResponse *httpResponse, NSData *httpResponseBodyData))successBlock httpErrorBlock:(void(^)(NSInteger code, NSHTTPURLResponse *httpResponse, NSData *httpResponseData))httpErrorBlock errorBlock:(void(^)(NSString *errStr, NSError *err))errorBlock completeBlock:(void(^)(NSURLConnection*conn))completeBlock;

- (NSURLConnectionWithBlocks *)connectionCopyWithRequest:(NSURLRequest *)httpRequest;
@end
