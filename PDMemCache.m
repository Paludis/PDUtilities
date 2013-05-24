//
//  PDMemCache.m
//  Geospike
//
//  Created by Peter Denniss on 8/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PDMemCache.h"

static PDMemCache* sharedInstance = nil;

@implementation PDMemCache

- (id) init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCache) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCache) name:UIApplicationDidEnterBackgroundNotification object:nil];
        cache = [NSMutableDictionary new];
    }
    return self;
}

- (void) clearCache
{
    [cache removeAllObjects];
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedInstance == nil) {
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


+ (PDMemCache*) sharedCache 
{
    @synchronized (self) {
        if (sharedInstance == nil){
            [self new];
        }
    }
    return sharedInstance;
}

- (void) setObject:(id)object forPath:(NSString *)path
{
    if (object != nil)
    {
        [cache setObject:object forKey:path];
    }
}

- (id) objectForPath:(NSString *)path
{
    if (path)
    {
        return [cache objectForKey:path];
    }
    else
    {
        return nil;
    }
}


@end
