#import <Foundation/Foundation.h>

@interface NSArray (Additions)
- (NSMutableArray*)nullFreeRecords;
@end

@interface NSMutableArray (Additions)
- (void)removeFirstObject;
@end