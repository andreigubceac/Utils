#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (Additions)

- (NSArray*)fetchObjectsForEntityName:(NSString *)newEntityName
                    propertiesToFetch:(NSArray*)propertiesToFetch
                             sortedBy:(id)stringOrArray ascending:(BOOL)o
                        withPredicate:(id)stringOrPredicate, ...;

- (NSArray*)fetchObjectsForEntityName:(NSString *)newEntityName
                    propertiesToFetch:(NSArray*)propertiesToFetch
                             sortedBy:(id)stringOrArray ascending:(BOOL)o withLimit:(NSUInteger)limit withPredicate:(id)stringOrPredicate, ...;

- (NSSet *)fetchObjectsForEntityName:(NSString *)newEntityName
                       withPredicate:(id)stringOrPredicate, ...;


- (NSManagedObject*) fetchObjectForEntityName:(NSString *)newEntityName
                                withPredicate:(id)stringOrPredicate, ...;

- (NSUInteger)countOfObjectsForEntityName:(NSString *)newEntityName
                            withPredicate:(id)stringOrPredicate, ...;

- (NSUInteger)countOfObjectsForEntityName:(NSString *)newEntityName
                                 sortedBy:(id)stringOrArray ascending:(BOOL)o
                                withLimit:(NSUInteger)limit
                            withPredicate:(id)stringOrPredicate, ...;


- (NSManagedObject*) fetchRandomObjectForEntityName:(NSString *)entityName;

@end

typedef void(^CreateOrUpdateSplitBlock)(BOOL success, NSArray *missingIds, NSArray* foundObjects, NSError* fetchError);

typedef void(^ErrorHandlerBlock)(NSError* error);


@interface NSManagedObjectContext (Extensions)

- (id) executeFetchFirstRequest:(NSFetchRequest *)request;

- (id) executeFetchRandomRequest:(NSFetchRequest *)request;


- (void) bulkCreateOrUpdateEntities:(NSEntityDescription*)entity
                withEntityIDKeypath:(NSString*)entityIDPath
                    fromObjectsIDs:(NSArray*)objectIds
                        splitBlock:(CreateOrUpdateSplitBlock)splitBlock;


// convenience functions without NSError** param but with moc-wide error handler

- (void) setMocErrorHandlerBlock:(ErrorHandlerBlock)errorHandlerBlock;

- (NSArray*) executeFetchRequest:(NSFetchRequest *)request;
- (NSUInteger) countForFetchRequest:(NSFetchRequest *)request;

- (BOOL) save;

@end
