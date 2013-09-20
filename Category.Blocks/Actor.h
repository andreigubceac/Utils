#import <Foundation/Foundation.h>
#import "BlocksAdditions.h"

@interface Actor : NSObject
{
    BOOL shouldStop;
}

@property (nonatomic, assign) id userData;
@property (nonatomic, strong) NSTimer *sentinelTimer;
@property (nonatomic, strong) NSThread *workerThread, *launchThread;

- (NSThread *)validParentThread;

- (NSDate *)dateToRunBefore;

- (void)start;

- (void)initialize;

- (void)stop;

- (void)cleanup;

- (BOOL)isRunning;

- (void)onParentThreadDoBlock:(BasicBlock)block;

- (void)onWorkerThreadDoBlock:(BasicBlock)block;

@end

