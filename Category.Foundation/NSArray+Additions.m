#import "NSArray+Additions.h"

@implementation NSArray (Additions)
- (id)firstObject
{
    return ([self count]>0?[self objectAtIndex:0]:nil);
}

- (NSArray*)nullFreeRecords
{
    NSMutableArray *nullFreeRecords = [NSMutableArray array];
    for (id record in self) {
        if ([record isKindOfClass:[NSDictionary class]]) {
            [nullFreeRecords addObject:[record nullFreeRecords]];
        } else {
            [nullFreeRecords addObject:record];
        }
    }
    return nullFreeRecords;
}

@end

@implementation NSMutableArray (Additions)

- (void)removeFirstObject
{
    if ([self count] > 0) {
        [self removeObjectAtIndex:0];
    }
}

@end
