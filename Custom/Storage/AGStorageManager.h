//
//  AGStorageManager.h
//
//  Created by Andrei Gubceac on 11/16/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "Actor.h"
#import "NSArray+Additions.h"

extern NSString *kSyncCompletedNotificationName;

typedef void (^StoreCompleteBlock)(id res, NSError* err, BOOL dataFromLocal);
typedef void (^StoreProgressBlock)(NSString *message);

@interface AGStorageManager : Actor

+ (NSURL *)applicationCacheDirectory;
+ (NSURL *)applicationDocumentsDirectory;

- (BOOL)writeJSONResponse:(id)response toDiskWithIdentifier:(NSString*)identifier toUrl:(NSURL*)url;
- (BOOL)writeJSONResponse:(id)response toDiskWithIdentifier:(NSString*)identifier;//url = [AGStorageManager applicationCacheDirectory]

- (BOOL)deleteJSONDataRecordsForIdentifier:(NSString *)identifier toUrl:(NSURL*)url;
- (BOOL)deleteJSONDataRecordsForIdentifier:(NSString *)identifier;//url = [AGStorageManager applicationCacheDirectory]

- (NSDictionary *)JSONDictionaryForIdentifier:(NSString *)identifier fromUrl:(NSURL*)url;
- (NSDictionary *)JSONDictionaryForIdentifier:(NSString *)identifier;//url = [AGStorageManager applicationCacheDirectory]

@end
