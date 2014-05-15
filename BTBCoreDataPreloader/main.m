//
//  main.m
//  BTBCoreDataPreloader
//
//  Created by Barty Kim on 5/15/14.
//  Copyright (c) 2014 Bartysways. All rights reserved.
//

#import "LocalFileModel.h"


static NSManagedObjectModel *managedObjectModel()
{
    static NSManagedObjectModel *model = nil;
    if (model != nil) {
        return model;
    }
    
    NSString *path = [[NSProcessInfo processInfo] arguments][0];
    path = [path stringByDeletingPathExtension];
    
    NSURL *modelURL = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"momd"]];
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return model;
}

static NSManagedObjectContext *managedObjectContext()
{
    static NSManagedObjectContext *context = nil;
    if (context != nil) {
        return context;
    }

    @autoreleasepool {
        context = [[NSManagedObjectContext alloc] init];
        
        NSPersistentStoreCoordinator *coordinator = nil;
        coordinator = [[NSPersistentStoreCoordinator alloc]
                       initWithManagedObjectModel:managedObjectModel()];
        [context setPersistentStoreCoordinator:coordinator];
        
        NSString *STORE_TYPE = NSSQLiteStoreType;
        
        NSString *path = [[NSProcessInfo processInfo] arguments][0];
        path = [path stringByDeletingPathExtension];
        NSURL *url = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"sqlite"]];
        
//        NSError *error;
//        NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:STORE_TYPE configuration:nil URL:url options:nil error:&error];
        
        NSError *error;
        NSDictionary *options = @{ NSSQLitePragmasOption : @{@"journal_mode" : @"DELETE"} };
        NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:STORE_TYPE configuration:nil URL:url options:options error:&error];
        
        if (newStore == nil) {
            NSLog(@"Store Configuration Failure %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
        }
    }
    return context;
}

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
    // Create the managed object context
        NSManagedObjectContext *context = managedObjectContext();
        
   
    // Save the managed object context
        NSError *error = nil;
        if (![context save:&error])
        {
            NSLog(@"Error while saving %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
            exit(1);
        }
        
        NSError* err = nil;
        NSString* dataPath = [[NSBundle mainBundle] pathForResource:@"RootFolders" ofType:@"json"];
        NSArray* localFiels = [NSJSONSerialization
                               JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]
                               options:kNilOptions
                               error:&err];
        
        NSLog(@"Imported LocalFiels: %@", localFiels);
        
    //Insert to CoreData
        [localFiels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
        {
            LocalFileModel *localFileModel = nil;
            localFileModel = [NSEntityDescription
                              insertNewObjectForEntityForName:@"LocalFileModel"
                              inManagedObjectContext:context];
            localFileModel.fid = obj[@"fid"];
            localFileModel.is_dir = obj[@"is_dir"];
            localFileModel.size = obj[@"size"];
            localFileModel.name = obj[@"name"];
            localFileModel.created_date = [NSDate dateWithString:obj[@"created_date"]];
            localFileModel.modified_date = [NSDate dateWithString:obj[@"modified_date"]];
            localFileModel.downloaded_date = [NSDate dateWithString:obj[@"downloaded_date"]];
            localFileModel.parent_id = obj[@"parent_id"];
            localFileModel.saved_path = obj[@"saved_path"];
            localFileModel.preview_path = obj[@"preview_path"];
            
            NSError *error;
            if (![context save:&error])
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }];
        
    //TEST listing
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = nil;
        entity = [NSEntityDescription entityForName:@"LocalFileModel"
                             inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        for (LocalFileModel *model in fetchedObjects)
        {
            NSLog(@"Name: %@", model.name);
        }
    }
    return 0;
}

