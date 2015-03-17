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

- (BOOL)writeJSONResponse:(id)response toDiskWithIdentifier:(NSString*)identifier toUrl:(NSURL*)url
{
    if (url == nil)
        return NO;
    
    NSURL *fileURL = [NSURL URLWithString:identifier relativeToURL:url];
    NSArray *records = [nullToNil(response) nullFreeRecords];
    
    if (nil == records)
        return NO;
    
    NSData *_data = [NSJSONSerialization dataWithJSONObject:records options:NSJSONWritingPrettyPrinted error:nil];
    if (![_data writeToURL:fileURL atomically:YES]) {
        AGLog(@"Failed all attempts to save reponse to disk: %@", response);
        return NO;
    } else {
        NSNumber *file_size = nil;
        NSError *err = nil;
        [fileURL getResourceValue:&file_size forKey:NSURLFileSizeKey error:&err];
        AGLog(@"FileSize for %@: %@ [%@]", identifier, file_size, [fileURL path]);
    }
    return YES;
}

- (BOOL)writeJSONResponse:(id)response toDiskWithIdentifier:(NSString*)identifier
{
    return [self writeJSONResponse:response toDiskWithIdentifier:identifier toUrl:[AGStorageManager applicationCacheDirectory]];
}

- (BOOL)deleteJSONDataRecordsForIdentifier:(NSString *)identifier toUrl:(NSURL*)url
{
    if (url == nil)
        return NO;
    url = [NSURL URLWithString:identifier relativeToURL:url];
    NSError *error = nil;
    BOOL deleted = [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
    if (!deleted) {
        AGLog(@"Unable to delete JSON Records at %@, reason: %@", url, error);
    }
    return deleted;
}

- (BOOL)deleteJSONDataRecordsForIdentifier:(NSString *)identifier
{
    return [self deleteJSONDataRecordsForIdentifier:identifier toUrl:[AGStorageManager applicationCacheDirectory]];
}

- (NSDictionary *)JSONDictionaryForIdentifier:(NSString *)identifier fromUrl:(NSURL*)url
{
    if (url == nil)
        return nil;
    NSURL *fileURL = [NSURL URLWithString:identifier relativeToURL:url];
    NSData *_data = [NSData dataWithContentsOfURL:fileURL];
    return _data?[NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingAllowFragments error:nil]:nil;
}

- (NSDictionary *)JSONDictionaryForIdentifier:(NSString *)identifier
{
    return [self JSONDictionaryForIdentifier:identifier fromUrl:[AGStorageManager applicationCacheDirectory]];
}

- (NSArray *)JSONDataRecordsForIdentifier:(NSString *)identifier sortedByKey:(NSString *)key {
    NSDictionary *JSONDictionary = [self JSONDictionaryForIdentifier:identifier];
    NSArray *records = [JSONDictionary objectForKey:@"objects"];
    return [records sortedArrayUsingDescriptors:[NSArray arrayWithObject:
                                                 [NSSortDescriptor sortDescriptorWithKey:key ascending:YES]]];
}

@end
