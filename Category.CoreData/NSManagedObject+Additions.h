#import <CoreData/CoreData.h>

@interface NSManagedObject (Additions)

- (NSManagedObjectContext*) moc; // .moc: abbreviation for .managedObjectContext

+ (NSString *) entityName; // class methods require moc , but in this case we derive the entity name from the class name
- (NSString *) entityName;

+ (NSEntityDescription *) entityDescriptionInContext:(NSManagedObjectContext *)moc;
- (NSEntityDescription *) entityDescription;

+ (id) getOrCreateObjectWhere:(NSString *)property isEqualTo:(id)value inContext:(NSManagedObjectContext *)moc;
+ (id) getObjectWhere:(NSString *)property isEqualTo:(id)value inContext:(NSManagedObjectContext *)moc;
+ (id) insertNewObjectInContext:(NSManagedObjectContext *)moc;
+ (id) insertInMOC:(NSManagedObjectContext *)moc; // shortcut

- (void) delete;

- (void) detectConflictsMark;


// convenience methods so you can call [myDBobj executeFetchRequest...] instead of [myDBobj.managedObjectContext executeFetchRequest...]

- (NSArray *) executeFetchRequest:(NSFetchRequest *)request;
- (NSUInteger) executeCountRequest:(NSFetchRequest *)request;

- (id) executeFetchFirstRequest:(NSFetchRequest *)request;
- (id) executeFetchRandomRequest:(NSFetchRequest *)request;


// NSFetchRequest factory functions: they preconfigure .entity, (.predicate, .sortDescriptors, etc.)
// - moc infered from object in case of instance methods
// - entity set based on class

+ (NSFetchRequest *) requestAllInContext:(NSManagedObjectContext *)moc;
- (NSFetchRequest *) requestAll;

+ (NSFetchRequest *) requestAllSortBy:(NSString*)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)moc;
- (NSFetchRequest *) requestAllSortBy:(NSString*)sortTerm ascending:(BOOL)ascending;

+ (NSFetchRequest *) requestAllWithPredicate:(NSPredicate *)searchPredicate inContext:(NSManagedObjectContext *)moc;
- (NSFetchRequest *) requestAllWithPredicate:(NSPredicate *)searchPredicate;
+ (NSFetchRequest *) requestAllWithPredicate:(NSPredicate *)searchPredicate sortBy:(NSString*)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)moc;
- (NSFetchRequest *) requestAllWithPredicate:(NSPredicate *)searchPredicate sortBy:(NSString*)sortTerm ascending:(BOOL)ascending;

+ (NSFetchRequest *) requestAllWhere:(NSString *)property isEqualTo:(id)value inContext:(NSManagedObjectContext *)moc;
- (NSFetchRequest *) requestAllWhere:(NSString *)property isEqualTo:(id)value;
+ (NSFetchRequest *) requestAllWhere:(NSString *)property isEqualTo:(id)value sortBy:(NSString*)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)moc;
- (NSFetchRequest *) requestAllWhere:(NSString *)property isEqualTo:(id)value sortBy:(NSString*)sortTerm ascending:(BOOL)ascending;

+ (NSFetchRequest *) requestAllInValueList:(NSArray *)valueList keyPath:(id)keyPath inContext:(NSManagedObjectContext *)moc;
- (NSFetchRequest *) requestAllInValueList:(NSArray *)valueList keyPath:(id)keyPath;
+ (NSFetchRequest *) requestAllInValueList:(NSArray *)valueList keyPath:(id)keyPath sortBy:(NSString*)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)moc;
- (NSFetchRequest *) requestAllInValueList:(NSArray *)valueList keyPath:(id)keyPath sortBy:(NSString*)sortTerm ascending:(BOOL)ascending;

@end

@interface NSManagedObject (JSON)
- (void)updateWithJSONDict:(id)o;
- (BOOL)needToUpdateFromServer;
- (id)jsonDict;
@end

@interface NSString (CoreDataExtensions)

- (NSEntityDescription*)entityDescriptioninMOC:(NSManagedObjectContext*)moc;

@end
