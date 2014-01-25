#import <Foundation/Foundation.h>

@interface NSArray (Additions)
- (id)firstObject;
- (NSMutableArray*)nullFreeRecords;
@end

@interface NSMutableArray (Additions)
- (void)removeFirstObject;
@end