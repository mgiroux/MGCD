//
//  MGCD.h
//  MGCoreData
//
//  Created by Marc Giroux on 2015-04-15.
//  Copyright (c) 2015 Marc Giroux. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface MGCD : NSObject
{
    NSManagedObjectContext *managedObjectContext;
    NSManagedObjectModel *managedObjectModel;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    
    NSString *databaseFile;
    NSString *modelName;
}

/* Shared instance */
+ (instancetype)sharedMGCD;

/* Configurations */
- (void)setDBFile:(NSString *)dbfile withModel:(NSString *)model;

/* CoreData stuff */
- (void)refresh;
- (NSManagedObjectContext *)managedObjectContext;
- (void)saveContext;
- (id)newObjectWithEntityName:(NSString*)entityName;
- (NSFetchRequest *)getFetchRequestForObject:(NSString *)object;
- (NSArray *)executeRequest:(NSFetchRequest *)request;

@end
