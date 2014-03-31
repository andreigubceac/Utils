//
//  AGCoreDataManager.h
//
//  Created by Andrei Gubceac on 11/16/13.
//  Copyright (c) 2013. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface AGCoreDataManager : NSObject
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectContext *backgroundContext;
- (NSString*)fileName;//to override

- (void)verifyStoreMetaDataWithCompleteBlock:(void(^)(NSError*))block;
- (void)saveContext:(NSManagedObjectContext*)context;
- (void)saveContext;
- (void)saveBackgroundContext;

- (NSManagedObjectContext*)importContext;

+ (NSURL *)applicationStoreDirectory;
- (NSURL*)storeUrl;

@end

#ifdef DEBUG
#define AGLog(...) NSLog(@"%s@%i: %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])
#else
#define AGLog(...)
#endif