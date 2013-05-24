//
//  PDMemCache.h
//  Geospike
//
//  Created by Peter Denniss on 8/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDMemCache : NSObject
{
    NSMutableDictionary* cache;
}

- (id) objectForPath:(NSString*)path;
- (void) setObject:(id)object forPath:(NSString*)path;
+ (PDMemCache*) sharedCache;
- (void) clearCache;

@end
