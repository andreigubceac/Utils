//
//  AGStorageManager.m
//
//  Created by Andrei Gubceac on 11/16/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "AGStorageManager.h"

NSString *kSyncCompletedNotificationName = @"SyncCompletedNotificationName";

@implementation AGStorageManager
#pragma mark - File Management

- (NSURL *)applicationCacheDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)JSONDataRecordsDirectory{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *url = [NSURL URLWithString:@"JSONRecords/" relativeToURL:[self applicationCacheDirectory]];
    NSError *error = nil;
    if (![fileManager fileExistsAtPath:[url path]]) {
        [fileManager createDirectoryAtPath:[url path] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    return url;
}

- (void)removeJSONDataRecordsDirectory
{
    DLog(@"%d",[[NSFileManager defaultManager] removeItemAtURL:[self JSONDataRecordsDirectory] error:nil]);
}

- (void)writeJSONResponse:(id)response toDiskWithIdentifier:(NSString*)identifier
{
    NSURL *fileURL = [NSURL URLWithString:identifier relativeToURL:[self JSONDataRecordsDirectory]];
    NSArray *records = nullToNil(response);
    
    if (nil == records)
        return;
    
    if (![[records nullFreeRecords] writeToFile:[fileURL path] atomically:YES]) {
        NSAssert(false, @"fail");
        DLog(@"Failed all attempts to save reponse to disk: %@", response);
    } else {
        NSNumber *file_size = nil;
        NSError *err = nil;
        [fileURL getResourceValue:&file_size forKey:NSURLFileSizeKey error:&err];
        DLog(@"FileSize for %@: %@ [%@]", identifier, file_size, [fileURL path]);
    }
}

- (void)deleteJSONDataRecordsForIdentifier:(NSString *)identifier {
    NSURL *url = [NSURL URLWithString:identifier relativeToURL:[self JSONDataRecordsDirectory]];
    NSError *error = nil;
    BOOL deleted = [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
    if (!deleted) {
        DLog(@"Unable to delete JSON Records at %@, reason: %@", url, error);
    }
}

- (NSDictionary *)JSONDictionaryForIdentifier:(NSString *)identifier {
    NSURL *fileURL = [NSURL URLWithString:identifier relativeToURL:[self JSONDataRecordsDirectory]];
    return [NSDictionary dictionaryWithContentsOfURL:fileURL];
}

- (NSArray *)JSONDataRecordsForIdentifier:(NSString *)identifier sortedByKey:(NSString *)key {
    NSDictionary *JSONDictionary = [self JSONDictionaryForIdentifier:identifier];
    NSArray *records = [JSONDictionary objectForKey:@"objects"];
    return [records sortedArrayUsingDescriptors:[NSArray arrayWithObject:
                                                 [NSSortDescriptor sortDescriptorWithKey:key ascending:YES]]];
}

- (NSArray *)managedObjectsForClass:(NSString *)className sortedByKey:(NSString *)key usingArrayOfIds:(NSArray *)idArray inArrayOfIds:(BOOL)inIds {
    __block NSArray *results = nil;
    NSManagedObjectContext *managedObjectContext = [_coredataManager backgroundContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:className];
    NSPredicate *predicate;
    if (inIds) {
        predicate = [NSPredicate predicateWithFormat:@"id IN %@", idArray];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"NOT (id IN %@)", idArray];
    }
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:
                                      [NSSortDescriptor sortDescriptorWithKey:key ascending:YES]]];
    [managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }];
    
    return results;
}

- (NSArray *)managedObjectsToBeDeletedForClass:(NSString *)className
{
    __block NSArray *results = nil;
    NSManagedObjectContext *moc = [_coredataManager backgroundContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:className];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"updateDate != nil"];
    [fetchRequest setPredicate:predicate];
    [moc performBlockAndWait:^{
        NSError *error = nil;
        results = [moc executeFetchRequest:fetchRequest error:&error];
    }];
    
    return results;
}

- (void)deleteObjectsFromLocalStorageEntities:(NSString*)class withPredicate:(NSPredicate*)predicate withCompleteBlock:(StoreCompleteBlock)block
{
    [self onWorkerThreadDoBlock:^{
        NSArray *_allProducts = [_coredataManager.backgroundContext fetchObjectsForEntityName:class
                                                                                propertiesToFetch:nil
                                                                                         sortedBy:nil ascending:NO withPredicate:predicate];
        for (NSManagedObject *obj in _allProducts)
            [obj delete];
        [self executeSyncCompletedOperations];
        [self onParentThreadDoBlock:^{
            if (block)
                block(@([_allProducts count]),nil,YES);
        }];
    }];
}

- (void)deleteObjectsFromLocalStorageEntities:(NSString*)class withCompleteBlock:(StoreCompleteBlock)block
{
    [self deleteObjectsFromLocalStorageEntities:class withPredicate:nil withCompleteBlock:block];
}


- (void)processJSONDataRecordsForClass:(Class)class jsonFileName:(NSString*)jsonfileName
  withStoredRecordsFromArrayOfIdsBlock:(NSArray*(^)(NSArray* jids))block
                                update:(void (^)(id object, NSDictionary* record))update withCompleteBlock:(BasicBlock)cblock
{
    NSManagedObjectContext *managedObjectContext = [_coredataManager backgroundContext];
    NSString *class_name = NSStringFromClass(class);
    
    NSArray *downloadedRecords = [self JSONDataRecordsForIdentifier:(jsonfileName?jsonfileName:class_name) sortedByKey:@"id"];
    id _lastObject = [downloadedRecords lastObject];
    
    if (nil != _lastObject) {
        NSArray *storedRecords = nil;
        NSArray *JSONIDS = [downloadedRecords valueForKey:@"id"];
        if (block)
            storedRecords = block(JSONIDS);
        else
            storedRecords = [self managedObjectsForClass:class_name sortedByKey:@"id" usingArrayOfIds:JSONIDS inArrayOfIds:YES];
        
        // Loop through the recrods
        NSManagedObject *storedManagedObject = nil;
        
        for (id record in downloadedRecords) {
            NSArray *stored_objects = [storedRecords filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id = %@", @([record[@"id"] intValue])]];
            if (stored_objects.count > 1) {
                for (NSManagedObject *managed_obj in [stored_objects subarrayWithRange:NSMakeRange(1, stored_objects.count - 1)]) {
                    DLog(@"DUPLICATE: %@", managed_obj);
                    [managedObjectContext deleteObject:managed_obj];
                }
            } else if (stored_objects.count > 0) {
                storedManagedObject = stored_objects[0];
                if (update) update(storedManagedObject, record);
            } else {
                NSString *entityName = [class entityName];
                id obj = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:managedObjectContext];
                if (update) update(obj, record);
            }
        }
        
        [self executeSyncCompletedOperations];
        if (cblock)
            cblock();
    }
    else if (cblock)
        cblock();
    [self deleteJSONDataRecordsForIdentifier:(jsonfileName?jsonfileName:class_name)];
}

#pragma mark - Syncing

- (void)executeSyncCompletedOperations {
    
    OnThread([self workerThread], YES, ^{
        [_coredataManager saveBackgroundContext];
    });
    OnThread(self.launchThread, YES, ^{
        [_coredataManager saveContext];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSyncCompletedNotificationName object:nil];
    });
}


@end
