#import "NSManagedObject+Additions.h"
#import "NSManagedObjectContext+Additions.h"

@implementation NSManagedObject (Additions)

- (NSManagedObjectContext*) moc
{
    return self.managedObjectContext;
}

+ (NSString *) entityName
{
    return NSStringFromClass(self);
}

- (NSString *) entityName
{
    return [[self entity] name];
}

+ (NSEntityDescription *) entityDescriptionInContext:(NSManagedObjectContext *)moc{
    NSString *entityName = [[self class]  entityName];
    NSEntityDescription *descr = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    return descr;
}

- (NSEntityDescription *) entityDescription{
    return [self entity];
}

+ (id) getOrCreateObjectWhere:(NSString *)property isEqualTo:(id)value inContext:(NSManagedObjectContext *)moc {
    NSFetchRequest *request = [self requestAllWhere:property isEqualTo:value inContext:moc];
    NSError *error = nil;
    NSArray *objs = [moc executeFetchRequest:request error:&error];
    if (objs.count == 0) {
        id obj = [self insertNewObjectInContext:moc];
        return obj;
    } else if (objs.count > 1) {
        NSLog(@"ERROR: GetOrCreateObjectWhere fetchedResults.count > 1");
    }
    return [objs lastObject];
}

+ (id) getObjectWhere:(NSString *)property isEqualTo:(id)value inContext:(NSManagedObjectContext *)moc {
    NSFetchRequest *request = [self requestAllWhere:property isEqualTo:value inContext:moc];
    NSError *error = nil;
    NSArray *objs = [moc executeFetchRequest:request error:&error];
    if (objs.count == 0) {
        return nil;
    } else if (objs.count > 1) {
        NSLog(@"ERROR: GetOrCreateObjectWhere fetchedResults.count > 1");
    }
    return [objs lastObject];
}


+ (id) insertNewObjectInContext:(NSManagedObjectContext *)moc{
    NSString *entityName = [[self class]  entityName];
    id obj = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc];
    return obj;
}

+ (id) insertInMOC:(NSManagedObjectContext *)moc{
    return [[self class] insertNewObjectInContext:moc];
}

- (void) delete{
	[self.managedObjectContext deleteObject:self];
}


- (void) detectConflictsMark{
    [self.managedObjectContext detectConflictsForObject:self];
}



- (NSArray *) executeFetchRequest:(NSFetchRequest *)request {
    return [self.managedObjectContext  executeFetchRequest:request];
}

- (NSUInteger) executeCountRequest:(NSFetchRequest *)request {
    return [self.managedObjectContext countForFetchRequest:request];
}

- (id) executeFetchFirstRequest:(NSFetchRequest *)request {
    return [self.managedObjectContext  executeFetchFirstRequest:request];
}

- (id) executeFetchRandomRequest:(NSFetchRequest *)request {
    return [self.managedObjectContext  executeFetchRandomRequest:request];
}



+ (NSFetchRequest *) requestAllInContext:(NSManagedObjectContext *)moc{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [self  entityDescriptionInContext:moc];
    return request;
}

- (NSFetchRequest *) requestAll{
    return [[self class] requestAllInContext:self.managedObjectContext];
}


+ (NSFetchRequest *) requestAllSortBy:(NSString*)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)moc{
	return [self requestAllWithPredicate:nil sortBy:sortTerm ascending:ascending inContext:moc];
}

- (NSFetchRequest *) requestAllSortBy:(NSString*)sortTerm ascending:(BOOL)ascending{
    return [[self class] requestAllSortBy:sortTerm ascending:ascending inContext:self.managedObjectContext];
}


+ (NSFetchRequest *) requestAllWithPredicate:(NSPredicate *)searchPredicate inContext:(NSManagedObjectContext *)moc{
	return [self requestAllWithPredicate:searchPredicate sortBy:nil ascending:NO inContext:moc];
}

- (NSFetchRequest *) requestAllWithPredicate:(NSPredicate *)searchPredicate{
    return [[self class] requestAllWithPredicate:searchPredicate inContext:self.managedObjectContext];
}

+ (NSFetchRequest *) requestAllWithPredicate:(NSPredicate *)searchPredicate sortBy:(NSString*)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)moc{
	NSFetchRequest *request = [self requestAllInContext:moc];
    if (searchPredicate) {
        request.predicate = searchPredicate;
    }
    if (sortTerm) {
        NSSortDescriptor *sortDesciptor = [[NSSortDescriptor alloc] initWithKey:sortTerm ascending:ascending];
        request.sortDescriptors = [NSArray arrayWithObject:sortDesciptor];
    }
    return request;
}

- (NSFetchRequest *) requestAllWithPredicate:(NSPredicate *)searchPredicate sortBy:(NSString*)sortTerm ascending:(BOOL)ascending{
    return [[self class] requestAllWithPredicate:searchPredicate sortBy:sortTerm ascending:ascending inContext:self.managedObjectContext];
}


+ (NSFetchRequest *) requestAllWhere:(NSString *)property isEqualTo:(id)value inContext:(NSManagedObjectContext *)moc{
    return [self requestAllWhere:property isEqualTo:value sortBy:nil ascending:NO inContext:moc];
}

- (NSFetchRequest *) requestAllWhere:(NSString *)property isEqualTo:(id)value {
    return [[self class] requestAllWhere:property isEqualTo:value inContext:self.managedObjectContext];
}


+ (NSFetchRequest *) requestAllWhere:(NSString *)property isEqualTo:(id)value sortBy:(NSString*)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)moc{
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"%K = %@", property, value];
    return [self requestAllWithPredicate:searchPredicate sortBy:sortTerm ascending:ascending inContext:moc];
}

- (NSFetchRequest *) requestAllWhere:(NSString *)property isEqualTo:(id)value sortBy:(NSString*)sortTerm ascending:(BOOL)ascending{
    return [[self class] requestAllWhere:property isEqualTo:value sortBy:sortTerm ascending:ascending inContext:self.managedObjectContext];
}


+ (NSFetchRequest *) requestAllInValueList:(NSArray *)valueList keyPath:(id)keyPath inContext:(NSManagedObjectContext *)moc{
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"(%K IN %@)", keyPath, valueList];
    return [self requestAllWithPredicate:searchPredicate inContext:moc];
}

- (NSFetchRequest *) requestAllInValueList:(NSArray *)valueList keyPath:(id)keyPath{
    return [[self class] requestAllInValueList:valueList keyPath:keyPath inContext:self.managedObjectContext];
}

+ (NSFetchRequest *) requestAllInValueList:(NSArray *)valueList keyPath:(id)keyPath sortBy:(NSString*)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)moc{
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"(%K IN %@)", keyPath, valueList];
    return [self requestAllWithPredicate:searchPredicate sortBy:sortTerm ascending:ascending inContext:moc];
}

- (NSFetchRequest *) requestAllInValueList:(NSArray *)valueList keyPath:(id)keyPath sortBy:(NSString*)sortTerm ascending:(BOOL)ascending{
    return [[self class] requestAllInValueList:valueList keyPath:keyPath sortBy:sortTerm ascending:ascending inContext:self.managedObjectContext];
}

@end


@implementation NSString (CoreDataExtensions)

- (NSEntityDescription*)entityDescriptioninMOC:(NSManagedObjectContext*)moc
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:self inManagedObjectContext:moc];
    return entity;
}

@end
