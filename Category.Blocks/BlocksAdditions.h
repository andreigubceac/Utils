#import <Foundation/Foundation.h>

typedef void (^BasicBlock)(void);
typedef void (^SuccessBlock)(id res);
typedef void (^ResultBlock)(id res);
typedef void (^ErrorBlock)(NSString *err);
typedef void (^CommunicationErrorBlock)(NSInteger code, NSError* errObj);


void InBackground(BasicBlock block);
void OnMainThread(BOOL shouldWait, BasicBlock block);
void OnThread(NSThread *thread, BOOL shouldWait, BasicBlock block);
void AfterDelay(NSTimeInterval delay, BasicBlock block);
void WithAutoreleasePool(BasicBlock block);
void Parallelized(int count, void (^block)(int i));
void InLocalizedCGContext(void(^block)(void));
void InTryCatch(void(^block)(void), void(^cleanup)(void), BOOL shouldRethrow);


@interface NSLock (BlocksAdditions)

- (void) whileLocked:(BasicBlock) block;

@end

typedef void (^DeallocBlock)(id);

@interface DeallocBlockValue : NSObject
{
    
}

@property (nonatomic, strong) NSValue *value;
@property (nonatomic, copy) DeallocBlock deallocBlock;

+ (DeallocBlockValue *)valueWithPointer:(const void *)aPointer deallocBlock:(DeallocBlock)block;

- (const void *)pointerValue;

@end