#import <Foundation/Foundation.h>

@interface NSDictionary (Additions)
- (NSDictionary*)dictionaryWithNullValuesRemoved;
- (NSDictionary*)nullFreeRecords;
@end
