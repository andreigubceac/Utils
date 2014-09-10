//
//  AGStorageManager.m
//
//  Created by Andrei Gubceac on 11/16/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "AGStorageManager.h"
#import "NSObject+Additions.h"

NSString *kSyncCompletedNotificationName = @"SyncCompletedNotificationName";

#ifdef DEBUG
#define AGLog(...) NSLog(@"%s@%i: %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])
#else
#define AGLog(...)
#endif

@implementation AGStorageManager
#pragma mark - File Management

+ (NSURL *)applicationCacheDirectory
{
    static NSURL *_cacheUrl = nil;
    if (_cacheUrl)
        return _cacheUrl;
    _cacheUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    _cacheUrl = [_cacheUrl URLByAppendingPathComponent:[NSObject bundleIdentifier]];
    return _cacheUrl;
}

+ (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)writeJSONResponse:(id)response toDiskWithIdentifier:(NSString*)identifier
{
    NSURL *fileURL = [NSURL URLWithString:identifier relativeToURL:[AGStorageManager applicationCacheDirectory]];
    NSArray *records = [nullToNil(response) nullFreeRecords];
    
    if (nil == records)
        return;
    
    NSData *_data = [NSJSONSerialization dataWithJSONObject:records options:NSJSONWritingPrettyPrinted error:nil];
    if (![_data writeToURL:fileURL atomically:YES]) {
        AGLog(@"Failed all attempts to save reponse to disk: %@", response);
    } else {
        NSNumber *file_size = nil;
        NSError *err = nil;
        [fileURL getResourceValue:&file_size forKey:NSURLFileSizeKey error:&err];
        AGLog(@"FileSize for %@: %@ [%@]", identifier, file_size, [fileURL path]);
    }
}

- (void)deleteJSONDataRecordsForIdentifier:(NSString *)identifier {
    NSURL *url = [NSURL URLWithString:identifier relativeToURL:[AGStorageManager applicationCacheDirectory]];
    NSError *error = nil;
    BOOL deleted = [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
    if (!deleted) {
        AGLog(@"Unable to delete JSON Records at %@, reason: %@", url, error);
    }
}

- (NSDictionary *)JSONDictionaryForIdentifier:(NSString *)identifier {
    NSURL *fileURL = [NSURL URLWithString:identifier relativeToURL:[AGStorageManager applicationCacheDirectory]];
    NSData *_data = [NSData dataWithContentsOfURL:fileURL];
    return _data?[NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingAllowFragments error:nil]:nil;
}

- (NSArray *)JSONDataRecordsForIdentifier:(NSString *)identifier sortedByKey:(NSString *)key {
    NSDictionary *JSONDictionary = [self JSONDictionaryForIdentifier:identifier];
    NSArray *records = [JSONDictionary objectForKey:@"objects"];
    return [records sortedArrayUsingDescriptors:[NSArray arrayWithObject:
                                                 [NSSortDescriptor sortDescriptorWithKey:key ascending:YES]]];
}

@end
