//
//  PDJsonUtils.h
//  zedalert
//
//  Created by Peter Denniss on 26/10/11.
//  Copyright (c) 2011 GO1 Pty Ltd. All rights reserved.
//

#ifndef SITE_URL
#define SITE_URL @""
#endif

#import <Foundation/Foundation.h>

@interface PDJsonUtils : NSObject

+ (NSString *)stringWithUrl:(NSURL *)url;
+ (id) objectWithUrl:(NSURL *)url;
+ (NSDictionary *) downloadJsonDictionaryFromURL:(NSString*)url;
+ (NSArray *) getArrayFromLocalJson:(NSString*) filename;
+ (NSDictionary *) getDictionaryFromLocalJson:(NSString*) filename;
+ (NSArray*) downloadJsonArrayFromURL:(NSString*)url;
+ (NSArray*) downloadJsonArrayFromPath:(NSString*)path;
+ (NSDictionary*) downloadJsonDictionaryFromPath:(NSString*)path;
+ (NSDictionary*) downloadJsonDictionaryFromPath:(NSString*)path withArguments:(NSDictionary*)args;

@end
