//
//  AGStorageManager.h
//
//  Created by Andrei Gubceac on 11/16/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "Actor.h"
#import "AGCoreDataManager.h"

#import "NSManagedObject+Additions.h"
#import "NSManagedObjectContext+Additions.h"
#import "NSArray+Additions.h"

extern NSString *kSyncCompletedNotificationName;

typedef void (^StoreCompleteBlock)(id res, NSError* err, BOOL dataFromLocal);
typedef void (^StoreProgressBlock)(NSString *message);

@interface AGStorageManager : Actor
{
    AGCoreDataManager *_coredataManager;//optionaly
}
- (void)writeJSONResponse:(id)response toDiskWithIdentifier:(NSString*)identifier;
- (void)deleteJSONDataRecordsForIdentifier:(NSString *)identifier;
- (NSDictionary *)JSONDictionaryForIdentifier:(NSString *)identifier;
@end
