#import "NSManagedObjectContext+Additions.h"
#import "NSManagedObject+Additions.h"

#import <objc/runtime.h>
#import <stdlib.h>

@implementation NSManagedObjectContext (Additions)

- (NSArray*)fetchObjectsForEntityName:(NSString *)newEntityName
                    propertiesToFetch:(NSArray*)propertiesToFetch
                             sortedBy:(id)stringOrArray ascending:(BOOL)o
                        withPredicate:(id)stringOrPredicate, ...
{
    
	NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:newEntityName inManagedObjectContext:self];
    
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	if (propertiesToFetch)
        [request setPropertiesToFetch:propertiesToFetch];
    [request setReturnsObjectsAsFaults:YES];
	if (stringOrArray)
	{
		NSArray *sortDescriptors;
		if ([stringOrArray isKindOfClass:[NSString class]]) {
			NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:stringOrArray ascending:o];
			sortDescriptors = [NSArray arrayWithObjects:desc, nil];
		} else {
			NSAssert2([stringOrArray isKindOfClass:[NSArray class]],
                      @"Second parameter passed to %s is of unexpected class %@",
                      sel_getName(_cmd), NSStringFromClass([stringOrArray class]));
			sortDescriptors = (NSArray*)stringOrArray;
		}
		[request setSortDescriptors:sortDescriptors];
        
	}
	
	if (stringOrPredicate)
	{
		NSPredicate *predicate;
		if ([stringOrPredicate isKindOfClass:[NSString class]])
		{
			va_list variadicArguments;
			va_start(variadicArguments, stringOrPredicate);
			predicate = [NSPredicate predicateWithFormat:stringOrPredicate
                                               arguments:variadicArguments];
			va_end(variadicArguments);
		}
		else
		{
			NSAssert2([stringOrPredicate isKindOfClass:[NSPredicate class]],
                      @"Second parameter passed to %s is of unexpected class %@",
                      sel_getName(_cmd), NSStringFromClass([stringOrPredicate class]));
			predicate = (NSPredicate *)stringOrPredicate;
		}
		[request setPredicate:predicate];
	}
    
	NSArray *results = [self  executeFetchRequest:request];
	return results;
    
}

- (NSUInteger) countOfObjectsForEntityName:(NSString *)newEntityName withPredicate:(id)stringOrPredicate, ...
{
 	NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:newEntityName inManagedObjectContext:self];
    
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	
	if (stringOrPredicate)
	{
		NSPredicate *predicate;
		if ([stringOrPredicate isKindOfClass:[NSString class]])
		{
			va_list variadicArguments;
			va_start(variadicArguments, stringOrPredicate);
			predicate = [NSPredicate predicateWithFormat:stringOrPredicate
                                               arguments:variadicArguments];
			va_end(variadicArguments);
		}
		else
		{
			NSAssert2([stringOrPredicate isKindOfClass:[NSPredicate class]],
                      @"Second parameter passed to %s is of unexpected class %@",
                      sel_getName(_cmd), NSStringFromClass([stringOrPredicate class]));
			predicate = (NSPredicate *)stringOrPredicate;
		}
		[request setPredicate:predicate];
	}
    
    NSUInteger count = [self countForFetchRequest:request];
    return count;
}

- (NSUInteger)countOfObjectsForEntityName:(NSString *)newEntityName
                                 sortedBy:(id)stringOrArray ascending:(BOOL)o withLimit:(NSUInteger)limit withPredicate:(id)stringOrPredicate, ...
{
 	NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:newEntityName inManagedObjectContext:self];
    
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
    [request setFetchLimit:limit];
	
	if (stringOrArray)
	{
		NSArray *sortDescriptors;
		if ([stringOrArray isKindOfClass:[NSString class]]) {
			NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:stringOrArray ascending:o];
			sortDescriptors = [NSArray arrayWithObjects:desc, nil];
		} else {
			NSAssert2([stringOrArray isKindOfClass:[NSArray class]],
                      @"Second parameter passed to %s is of unexpected class %@",
                      sel_getName(_cmd), NSStringFromClass([stringOrArray class]));
			sortDescriptors = (NSArray*)stringOrArray;
		}
		[request setSortDescriptors:sortDescriptors];
	}
    
	
	if (stringOrPredicate)
	{
		NSPredicate *predicate;
		if ([stringOrPredicate isKindOfClass:[NSString class]])
		{
			va_list variadicArguments;
			va_start(variadicArguments, stringOrPredicate);
			predicate = [NSPredicate predicateWithFormat:stringOrPredicate
                                               arguments:variadicArguments];
			va_end(variadicArguments);
		}
		else
		{
			NSAssert2([stringOrPredicate isKindOfClass:[NSPredicate class]],
                      @"Second parameter passed to %s is of unexpected class %@",
                      sel_getName(_cmd), NSStringFromClass([stringOrPredicate class]));
			predicate = (NSPredicate *)stringOrPredicate;
		}
		[request setPredicate:predicate];
	}
    
    NSUInteger count = [self countForFetchRequest:request];
    return count;
    
}


// Convenience method to fetch the array of objects for a given Entity
// name in the context, optionally limiting by a predicate or by a predicate
// made from a format NSString and variable arguments.
//
- (NSSet *)fetchObjectsForEntityName:(NSString *)newEntityName
                       withPredicate:(id)stringOrPredicate, ...
{
	NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:newEntityName inManagedObjectContext:self];
    
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	
	if (stringOrPredicate)
	{
		NSPredicate *predicate;
		if ([stringOrPredicate isKindOfClass:[NSString class]])
		{
			va_list variadicArguments;
			va_start(variadicArguments, stringOrPredicate);
			predicate = [NSPredicate predicateWithFormat:stringOrPredicate
                                               arguments:variadicArguments];
			va_end(variadicArguments);
		}
		else
		{
			NSAssert2([stringOrPredicate isKindOfClass:[NSPredicate class]],
                      @"Second parameter passed to %s is of unexpected class %@",
                      sel_getName(_cmd), NSStringFromClass([stringOrPredicate class]));
			predicate = (NSPredicate *)stringOrPredicate;
		}
		[request setPredicate:predicate];
	}
    
	NSArray *results = [self  executeFetchRequest:request];
	
	return [NSSet setWithArray:results];
}

- (NSArray*)fetchObjectsForEntityName:(NSString *)newEntityName
                    propertiesToFetch:(NSArray*)propertiesToFetch
                             sortedBy:(id)stringOrArray ascending:(BOOL)o withLimit:(NSUInteger)limit withPredicate:(id)stringOrPredicate, ...
{
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:newEntityName inManagedObjectContext:self];
    
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setFetchLimit:limit];
	[request setEntity:entity];
    if (propertiesToFetch)
        [request setPropertiesToFetch:propertiesToFetch];
	if (stringOrArray)
	{
		NSArray *sortDescriptors;
		if ([stringOrArray isKindOfClass:[NSString class]]) {
			NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:stringOrArray ascending:o];
			sortDescriptors = [NSArray arrayWithObjects:desc, nil];
		} else {
			NSAssert2([stringOrArray isKindOfClass:[NSArray class]],
                      @"Second parameter passed to %s is of unexpected class %@",
                      sel_getName(_cmd), NSStringFromClass([stringOrArray class]));
			sortDescriptors = (NSArray*)stringOrArray;
		}
		[request setSortDescriptors:sortDescriptors];
        
	}
	
	if (stringOrPredicate)
	{
		NSPredicate *predicate;
		if ([stringOrPredicate isKindOfClass:[NSString class]])
		{
			va_list variadicArguments;
			va_start(variadicArguments, stringOrPredicate);
			predicate = [NSPredicate predicateWithFormat:stringOrPredicate
                                               arguments:variadicArguments];
			va_end(variadicArguments);
		}
		else
		{
			NSAssert2([stringOrPredicate isKindOfClass:[NSPredicate class]],
                      @"Second parameter passed to %s is of unexpected class %@",
                      sel_getName(_cmd), NSStringFromClass([stringOrPredicate class]));
			predicate = (NSPredicate *)stringOrPredicate;
		}
		[request setPredicate:predicate];
	}
    
	NSArray *results = [self  executeFetchRequest:request];
    
	return results;
}

- (NSManagedObject*) fetchObjectForEntityName:(NSString *)newEntityName
                                withPredicate:(id)stringOrPredicate, ...
{
	NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:newEntityName inManagedObjectContext:self];
    
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	[request setFetchLimit:1];
	
	if (stringOrPredicate)
	{
		NSPredicate *predicate;
		if ([stringOrPredicate isKindOfClass:[NSString class]])
		{
			va_list variadicArguments;
			va_start(variadicArguments, stringOrPredicate);
			predicate = [NSPredicate predicateWithFormat:stringOrPredicate
                                               arguments:variadicArguments];
			va_end(variadicArguments);
		}
		else
		{
			NSAssert2([stringOrPredicate isKindOfClass:[NSPredicate class]],
                      @"Second parameter passed to %s is of unexpected class %@",
                      sel_getName(_cmd), NSStringFromClass([stringOrPredicate class]));
			predicate = (NSPredicate *)stringOrPredicate;
		}
		[request setPredicate:predicate];
	}
    
	NSArray *results = [self  executeFetchRequest:request];
	
    id result = (results.count > 0) ? [results objectAtIndex:0] : nil;
    
	return result;
}

- (NSManagedObject*) fetchRandomObjectForEntityName:(NSString *)entityName
{
    NSManagedObject *randomObject = nil;
    NSError *error = nil;
    
    NSFetchRequest *randomRequest = [[NSFetchRequest alloc] init];
    randomRequest.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self];
    
    if (randomRequest.entity)
    {
        NSUInteger entityCount = [self countForFetchRequest:randomRequest error:&error];
        
        if (!error && entityCount != NSNotFound && entityCount > 0) {
            NSUInteger offset = entityCount - (arc4random() % entityCount);
            [randomRequest setFetchOffset:offset];
            [randomRequest setFetchLimit:1];
            
            NSArray* objects = [self  executeFetchRequest:randomRequest];
            if (objects.count > 0) {
                randomObject = [objects objectAtIndex:0];
            }
        }
    }
    
    return randomObject;
}

@end

@implementation NSManagedObjectContext (Extensions)


- (id) executeFetchFirstRequest:(NSFetchRequest *)request
{
    id firstResult = nil;
    request.fetchLimit = 1;
    NSArray *fetchedResults = [self  executeFetchRequest:request];
    if (fetchedResults.count > 0) {
        firstResult = [fetchedResults objectAtIndex:0];
    } else {
        NSLog(@"WARN:  executeFetchFirstRequest fetchedResults.count == 0");
    }
    return firstResult;
}


- (id) executeFetchRandomRequest:(NSFetchRequest *)request
{
    NSManagedObject *randomObject = nil;
    NSUInteger entityCount = 0;
    
    NSArray* objects = [self  executeFetchRequest:request];
    entityCount = [objects count];
    
    if (entityCount > 0) {
        u_int32_t randomInt = arc4random();
        NSUInteger offset = randomInt % entityCount;
        randomObject = [objects objectAtIndex:offset];
    }
    return randomObject;
}


- (void) bulkCreateOrUpdateEntities:(NSEntityDescription*)entity
                   withEntityIDKeypath:(NSString*)entityIDPath
                        fromObjectsIDs:(NSArray*)objectIds
                            splitBlock:(CreateOrUpdateSplitBlock)splitBlock
{
    NSAssert(splitBlock, @"splitBlock == nil");
    if (splitBlock == NULL)
        return; // caller aparently not interested in the result
    
    NSAssert((!entity || entityIDPath.length == 0 || objectIds.count == 0), @"(!entity || entityIDPath.length == 0 || objectIds.count == 0) == FALSE");
    if (!entity || entityIDPath.length == 0 || objectIds.count == 0) {
        splitBlock(NO, objectIds, nil, nil);
        return;
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.predicate = [NSPredicate predicateWithFormat:@"(%K IN %@)", entityIDPath, objectIds];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:entityIDPath ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *foundObjects = [self executeFetchRequest:request error:&error];
    if (!foundObjects) {
        splitBlock(NO, objectIds, nil, error);
        return;
    }
    
    NSMutableArray *missingIds = [NSMutableArray arrayWithArray:objectIds];
    [foundObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *entityId = [obj objectForKey:entityIDPath];
        [missingIds removeObject:entityId];
    }];
    
    splitBlock(YES, missingIds, foundObjects, nil);
}


static const char *_s_MOCErrorHandlerBlock;

- (void)setMocErrorHandlerBlock:(ErrorHandlerBlock)errorHandlerBlock
{
    objc_setAssociatedObject(self, &_s_MOCErrorHandlerBlock, errorHandlerBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


-(NSArray*) executeFetchRequest:(NSFetchRequest *)request
{
    NSError *error = nil;
    NSArray *resultSet = [self executeFetchRequest:request error:&error];
    if (!resultSet) {
         ErrorHandlerBlock errorHandlerBlock = objc_getAssociatedObject(self, &_s_MOCErrorHandlerBlock);
        if (errorHandlerBlock) {
            errorHandlerBlock(error);
        }
    }
    return resultSet;
}

- (NSUInteger) countForFetchRequest:(NSFetchRequest *)request
{
    NSError *error = nil;
    NSUInteger resultCount = [self countForFetchRequest:request error:&error];
    if (resultCount == NSNotFound) {
         ErrorHandlerBlock errorHandlerBlock = objc_getAssociatedObject(self, &_s_MOCErrorHandlerBlock);
        if (errorHandlerBlock) {
            errorHandlerBlock(error);
        }
    }
    return resultCount;
}

-(BOOL)save
{
    NSError *error = nil;
    BOOL wasSaveOk = [self save:&error];
    if (!wasSaveOk) {
         ErrorHandlerBlock errorHandlerBlock = objc_getAssociatedObject(self, &_s_MOCErrorHandlerBlock);
        if (errorHandlerBlock) {
            errorHandlerBlock(error);
        }
    }
    return wasSaveOk;
}

@end
