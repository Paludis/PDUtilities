//
//  DataStorage.h
//  Bodyspanner
//
//  Created by Peter Denniss on 15/09/11.
//  Copyright 2011 Go1 Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDDataStorage : NSObject {
    
    NSMutableDictionary* storageDict;
    
}

- (void) removeObjectForKey:(NSString*)key;
- (void) setObject:(id)object forKey:(NSString*)key;
- (id) objectForKey:(NSString*)key;
- (void) save;
- (void) emptyStorage;
+ (PDDataStorage*) sharedStorage;

@end
