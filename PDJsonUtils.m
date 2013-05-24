//
//  PDJsonUtils.m
//  zedalert
//
//  Created by Peter Denniss on 26/10/11.
//  Copyright (c) 2011 GO1 Pty Ltd. All rights reserved.
//

#import "PDJsonUtils.h"
#import "PDUtilities.h"
#import "JSONKit.h"

@implementation PDJsonUtils

+ (NSString *)stringWithUrl:(NSURL *)url{
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
												cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
											timeoutInterval:30];
    
	// Fetch the JSON response
	NSData *urlData;
	NSURLResponse *response;
	NSError *error;
	
	// Make synchronous request
	urlData = [NSURLConnection sendSynchronousRequest:urlRequest
									returningResponse:&response
												error:&error];
    
    if (urlData == nil){
        // connection error;
    }
	
 	// Construct a String around the Data from the response
	return [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
}

+ (id) objectWithUrl:(NSURL *)url{
	NSString *jsonString = [self stringWithUrl:url];
    
    DLog(@"json string: %@", jsonString);
    
	// Parse the JSON into an Object
	return [jsonString objectFromJSONString];
}

+ (NSArray *) getArrayFromLocalJson:(NSString*) filename{
    
    id response = [self objectWithUrl:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:filename ofType:@"json"]isDirectory:NO]];
    
	NSArray *feed = (NSArray *)response;
	return feed;
    
}

+ (NSDictionary *) getDictionaryFromLocalJson:(NSString*) filename{
    id response = [self objectWithUrl:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:filename ofType:@"json"]isDirectory:NO]];
    
	NSDictionary *feed = (NSDictionary *)response;
	return feed;
}

+ (NSArray*) downloadJsonArrayFromURL:(NSString*)url{
   	id response = [self objectWithUrl:[NSURL URLWithString:url]];
	NSArray *feed = (NSArray *)response;
	return feed; 
}

+ (NSArray*) downloadJsonArrayFromPath:(NSString*)path{
	return [self downloadJsonArrayFromURL:[NSString stringWithFormat:SITE_URL@"/%@", path]]; 
}

+ (NSDictionary *) downloadJsonDictionaryFromURL:(NSString*)url{
	id response = [self objectWithUrl:[NSURL URLWithString:url]];
	NSDictionary *feed = (NSDictionary *)response;
	return feed;
}

+ (NSDictionary*) downloadJsonDictionaryFromPath:(NSString*)path{
	return [self downloadJsonDictionaryFromURL:[NSString stringWithFormat:SITE_URL@"/%@", path]]; 
}

+ (NSDictionary*) downloadJsonDictionaryFromPath:(NSString *)path withArguments:(NSDictionary *)args {
	
 	// Construct a String around the Data from the response
	NSString* jsonString = [PDUtilities sendRequestReturningStringToPath:path withArgs:args];
    DLog(@"json string: %@", jsonString);
	// Parse the JSON into an Object
    return [jsonString objectFromJSONString];    
    
}

@end
