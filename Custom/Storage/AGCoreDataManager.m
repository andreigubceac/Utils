//
//  AGCoreDataManager.m
//
//  Created by Andrei Gubceac on 11/16/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "AGCoreDataManager.h"

@implementation AGCoreDataManager
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize backgroundContext = _backgroundContext;

- (NSString*)fileName//to override
{
    return nil;
}
#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:[self fileName] withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [self storeUrl];

    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:@{NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption : @YES} error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        AGLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //        abort();
        AGLog(@"DELETING Old Store: %d",[[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]);
        _persistentStoreCoordinator = nil;
        _persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

- (NSURL*)storeUrl {
	return [[AGCoreDataManager applicationStoreDirectory] URLByAppendingPathComponent:[[self fileName] stringByAppendingPathExtension:@"sqlite"]];
}


// Returns the URL to the application's Documents directory.
+ (NSURL *)applicationStoreDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

// Return the NSManagedObjectContext to be used in the background during sync
- (NSManagedObjectContext *)backgroundContext {
    if (_backgroundContext != nil) {
        return _backgroundContext;
    }
    
    NSManagedObjectContext *masterContext = [self managedObjectContext];
    if (masterContext != nil) {
        _backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_backgroundContext performBlockAndWait:^{
            [_backgroundContext setParentContext:masterContext];
        }];
    }
    
    return _backgroundContext;
}

- (NSManagedObjectContext*)importContext
{
    NSManagedObjectContext *importContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [importContext performBlockAndWait:^{
        [importContext setParentContext:[self backgroundContext]];
    }];
    return importContext;
}

- (void)saveContext
{
    [self saveContext:self.managedObjectContext];
}

- (void)saveBackgroundContext {
    [self saveContext:[self backgroundContext]];
}

- (void)saveContext:(NSManagedObjectContext*)context
{
    [context performBlockAndWait:^{
        NSError *error = nil;
        BOOL saved = [context save:&error];
        if (!saved) {
            // do some real error handling
            AGLog(@"Could not save context due to %@", error);
            abort();
        }
        else
            [self saveContext:context.parentContext];
    }];
}

- (void)verifyStoreMetaDataWithCompleteBlock:(void(^)(NSError*))block
{
	NSError *error = nil;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:[[self storeUrl] path]])
	{
        [self progressivelyMigrateURL:[self storeUrl]
                               ofType:NSSQLiteStoreType
                              toModel:[self managedObjectModel]
                                error:&error];
    }
    if (block)
        block(error);
}

//START:progressivelyMigrateURLMethodName
- (BOOL)progressivelyMigrateURL:(NSURL*)sourceStoreURL ofType:(NSString*)type toModel:(NSManagedObjectModel*)finalModel error:(NSError**)error
{
    //END:progressivelyMigrateURLMethodName
    //START:progressivelyMigrateURLHappyCheck
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:type
                                                                                              URL:sourceStoreURL
                                                                                            error:error];
    if (!sourceMetadata) return NO;
    
    if ([finalModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata]) {
        *error = nil;
        return YES;
    }
    //END:progressivelyMigrateURLHappyCheck
    //START:progressivelyMigrateURLFindModels
    //Find the source model
    NSManagedObjectModel *sourceModel = [NSManagedObjectModel mergedModelFromBundles:nil
                                                                    forStoreMetadata:sourceMetadata];
    if (!sourceModel){
        //NSAssert(sourceModel != nil, ([NSString stringWithFormat:@"Failed to find source model\n%@", sourceMetadata]));
        *error = nil;
        return YES;
    }
    
    //Find all of the mom and momd files in the Resources directory
    NSMutableArray *modelPaths = [NSMutableArray array];
    NSArray *momdArray = [[NSBundle mainBundle] pathsForResourcesOfType:@"momd" inDirectory:nil];
    
    for (NSString *momdPath in momdArray) {
        NSString *resourceSubpath = [momdPath lastPathComponent];
        NSArray *array = [[NSBundle mainBundle] pathsForResourcesOfType:@"mom" inDirectory:resourceSubpath];
        [modelPaths addObjectsFromArray:array];
    }
    NSArray* otherModels = [[NSBundle mainBundle] pathsForResourcesOfType:@"mom" inDirectory:nil];
    [modelPaths addObjectsFromArray:otherModels];
    if (!modelPaths || ![modelPaths count]) {
        //Throw an error if there are no models
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"No models found in bundle" forKey:NSLocalizedDescriptionKey];
        //Populate the error
        *error = [NSError errorWithDomain:@"Zarra" code:8001 userInfo:dict];
        return NO;
    }
    //END:progressivelyMigrateURLFindModels
    
    //See if we can find a matching destination model
    //START:progressivelyMigrateURLFindMap
    NSMappingModel *mappingModel = nil;
    NSManagedObjectModel *targetModel = nil;
    NSString *modelPath = nil;
    for (modelPath in modelPaths) {
        targetModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]];
        mappingModel = [NSMappingModel mappingModelFromBundles:nil forSourceModel:sourceModel destinationModel:targetModel];
        //If we found a mapping model then proceed
        if (mappingModel) break;
        targetModel = nil;
    }
    //We have tested every model, if nil here we failed
    if (!mappingModel) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"No models found in bundle" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Zarra" code:8002 userInfo:dict];
        return NO;
    }
    //END:progressivelyMigrateURLFindMap
    //We have a mapping model and a destination model.  Time to migrate
    //START:progressivelyMigrateURLMigrate
    NSMigrationManager *manager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel destinationModel:targetModel];
    
    NSString *modelName = [[modelPath lastPathComponent] stringByDeletingPathExtension];
    NSString *storeExtension = [[sourceStoreURL path] pathExtension];
    NSString *storePath = [[sourceStoreURL path] stringByDeletingPathExtension];
    //Build a path to write the new store
    storePath = [NSString stringWithFormat:@"%@.%@.%@", storePath, modelName, storeExtension];
    NSURL *destinationStoreURL = [NSURL fileURLWithPath:storePath];
    
    if (![manager migrateStoreFromURL:sourceStoreURL
                                 type:type
                              options:nil
                     withMappingModel:mappingModel
                     toDestinationURL:destinationStoreURL
                      destinationType:type
                   destinationOptions:nil
                                error:error]) {
        return NO;
    }
    //END:progressivelyMigrateURLMigrate
    //Migration was successful, move the files around to preserve the source
    //START:progressivelyMigrateURLMoveAndRecurse
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
    guid = [guid stringByAppendingPathExtension:modelName];
    guid = [guid stringByAppendingPathExtension:storeExtension];
    NSString *appSupportPath = [storePath stringByDeletingLastPathComponent];
    NSString *backupPath = [appSupportPath stringByAppendingPathComponent:guid];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager moveItemAtPath:[sourceStoreURL path]
                              toPath:backupPath
                               error:error]) {
        //Failed to copy the file
        return NO;
    }
    //Move the destination to the source path
    if (![fileManager moveItemAtPath:storePath
                              toPath:[sourceStoreURL path]
                               error:error]) {
        //Try to back out the source move first, no point in checking it for errors
        [fileManager moveItemAtPath:backupPath
                             toPath:[sourceStoreURL path]
                              error:nil];
        return NO;
    }
    [fileManager removeItemAtPath:backupPath error:nil];
    //We may not be at the "current" model yet, so recurse
    return [self progressivelyMigrateURL:sourceStoreURL
                                  ofType:type
                                 toModel:finalModel
                                   error:error];
    //END:progressivelyMigrateURLMoveAndRecurse
}


@end
