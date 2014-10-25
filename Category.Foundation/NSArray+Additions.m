#import "NSArray+Additions.h"

@implementation NSArray (Additions)

- (NSMutableArray*)nullFreeRecords
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

@implementation NSArray (json)

- (NSArray*)jsonObject
{
    NSMutableArray *_arr = [self nullFreeRecords];
    int i = 0;
    while (i<_arr.count) {
        id _obj = [_arr objectAtIndex:i];
        [_arr replaceObjectAtIndex:i withObject:[_obj jsonObject]];
        i++;
    }
    return _arr;
}

@end
