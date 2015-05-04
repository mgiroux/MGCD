//
//  MGCD.m
//  MGCoreData
//
//  Created by Marc Giroux on 2015-04-15.
//  Copyright (c) 2015 Marc Giroux. All rights reserved.
//

#import "MGCD.h"

@implementation MGCD

+ (instancetype)sharedMGCD
{
    static MGCD *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (void)setDBFile:(NSString *)dbfile withModel:(NSString *)model
{
    databaseFile = dbfile;
    modelName    = model;
    
    [self managedObjectContext];
}

#pragma mark - CoreData Methods

- (void)refresh
{
    managedObjectContext       = nil;
    managedObjectModel         = nil;
    persistentStoreCoordinator = nil;
    
    [self managedObjectContext];
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    
    NSURL *modelURL    = [[NSBundle mainBundle] URLForResource:modelName withExtension:@"momd"];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL     = [documentsURL URLByAppendingPathComponent:databaseFile];
    NSError *error      = nil;
        
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"MGCD Unresolved error: %@, %@", error, [error userInfo]);
    }
    
    return persistentStoreCoordinator;
}

- (void)saveContext
{
    NSError *error = nil;
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (context != nil) {
        @try {
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
                NSLog(@"MGCD Error: %@", error);
            }
        }
        @catch (NSException *exception) {
            NSLog(@"MGCD Exception: %@", exception);
        }
    }
}

- (id)newObjectWithEntityName:(NSString*)entityName
{
    return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:[self managedObjectContext]];
}

- (NSFetchRequest *)getFetchRequestForObject:(NSString *)object
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity  = [NSEntityDescription entityForName:object inManagedObjectContext:[self managedObjectContext]];
    
    [fetchRequest setEntity:entity];
    return fetchRequest;
}

- (NSArray *)executeRequest:(NSFetchRequest *)request
{
    NSError *error;
    NSArray *results = [[self managedObjectContext] executeFetchRequest:request error:&error];
    
    if (error != nil) {
        NSLog(@"MGCD CoreData Error: %@", error);
    }
    
    return results;
}

@end
