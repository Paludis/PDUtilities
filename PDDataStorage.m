//
//  DataStorage.m
//  Bodyspanner
//
//  Created by Peter Denniss on 15/09/11.
//  Copyright 2011 Go1 Pty Ltd. All rights reserved.
//

#import "PDDataStorage.h"
#import "PDUtilities.h"

#define kFilename = @"PDDataStorage"

// ref: http://www.duckrowing.com/2010/05/21/using-the-singleton-pattern-in-objective-c/

static PDDataStorage* sharedInstance = nil;

@implementation PDDataStorage

- (id)init
{
    self = [super init];
    if (self)
    {
        // Initialization code here.
        
        storageDict = [NSKeyedUnarchiver unarchiveObjectWithFile:[PDUtilities getFilePathForFileInDocumentsDirectory:kFilename]];
        
        if (storageDict == nil){
            storageDict = [NSMutableDictionary new];
        }
    }
    
    return self;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
        {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;
        }
    }
    
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


+ (PDDataStorage*) sharedStorage
{
    @synchronized (self)
    {
        if (sharedInstance == nil)
        {
            [self new];
        }
    }
    return sharedInstance;
}

- (void) setObject:(id)object forKey:(NSString*)key
{
    if (object)
    {
        [storageDict setObject:object forKey:key];
    }
}

- (id) objectForKey:(NSString*)key
{
    return [storageDict objectForKey:key];
}

- (void) emptyStorage
{
    [storageDict removeAllObjects];
}

- (void) removeObjectForKey:(NSString *)key
{
    [storageDict removeObjectForKey:key];
}

- (void) save
{
    NSString* path = [PDUtilities getFilePathForFileInDocumentsDirectory:kFilename];
    [NSKeyedArchiver archiveRootObject:storageDict toFile:path];
}

@end
