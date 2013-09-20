#import "NSDictionary+Additions.h"
#import "NSArray+Additions.h"

@implementation NSDictionary (Additions)

- (NSDictionary*)dictionaryWithNullValuesRemoved
{
    NSSet *keys = [self keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        return obj != [NSNull null];
    }];
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:keys.count];
    for (id key in keys) {
        [d setObject:[self objectForKey:key] forKey:key];
    }
    return d;
}

- (NSDictionary*)nullFreeRecords
{
    NSMutableDictionary *nullFreeRecord = [NSMutableDictionary dictionaryWithDictionary:self];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSNull class]]) {
            [nullFreeRecord setValue:nil forKey:key];
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            //NSDictionary *sub_dict = [self valueForKey:key];
            [nullFreeRecord setValue:[obj nullFreeRecords] forKey:key];
        } else if ([obj isKindOfClass:[NSArray class]]) {
            //NSArray *sub_array = [self valueForKey:key];
            [nullFreeRecord setValue:[obj nullFreeRecords] forKey:key];
        } else {
            [nullFreeRecord setValue:obj forKey:key];
        }
    }];
    return nullFreeRecord;
}

@end
