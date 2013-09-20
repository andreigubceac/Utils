#import <Foundation/Foundation.h>

@interface NSArray (Additions)
- (id)firstObject;
- (NSArray*)nullFreeRecords;
@end

@interface NSMutableArray (Additions)
- (void)removeFirstObject;
@end