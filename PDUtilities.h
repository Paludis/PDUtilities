//
//  Utilities.h
//  ios-common
//
//  Created by Peter Denniss on 8/03/11.
//  Copyright 2011 Go1 Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <MapKit/MapKit.h>
#import "WDMapView.h"

@interface PDUtilities : NSObject <UIAlertViewDelegate> {

    int indicatorCount;
    BOOL alertShowing;
    
    NSMutableDictionary* alertTags;
}

#define kConnectionErrorTag 148194

// dynamic methods
- (void) showNetworkIndicator:(BOOL)on;
- (void) changeNetworkIndicator;
- (void) showConnectionError;   // only shows one alert at once so that connection errors don't stack up.
- (void) showAlertWithTitle:(NSString*)title message:(NSString*)message tag:(int)tag;

// static methods
+ (PDUtilities*) sharedUtilities;
+ (NSString *) returnMD5Hash:(NSString*)concat;
+ (void)resizeFontForLabel:(UILabel*)aLabel maxSize:(int)maxSize minSize:(int)minSize;
+ (NSString*) getFilePathForFileInDocumentsDirectory:(NSString*)filename;
+ (NSString*) sendRequestReturningStringToPath:(NSString*)path withArgs:(NSDictionary*) args;
+ (NSString *)generateSHA256Hash:(NSString *)inputString usingKey:(NSString*)key;
+ (NSString*)stringWithHexBytes:(NSData *)theData;
+ (NSString *) genRandStringLength;
+ (void) showAlertWithTitle:(NSString*)title message:(NSString*)message;
+ (void) showConnectionError;
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert;
+ (void) clearCookies;
+ (UIImage*)imageByScalingAndCroppingImage:(UIImage*)image forSize:(CGSize)targetSize;
+ (NSString*)getYoutubeEmbedCodeForVideoID:(NSString*)videoID size:(CGSize)size;
+ (BOOL) string:(NSString*)string1 containsString:(NSString*)substring;
+ (BOOL) isPortrait;
+ (NSString*) getPOSTMethodsStringFromDictionary:(NSDictionary*)dictionary;
+ (NSData*) sendRequestToPath:(NSString*)path withArgs:(NSDictionary*)args method:(NSString*)httpMethod;
+ (NSData*) sendRequestToURL:(NSString*)url withArgs:(NSDictionary*)args method:(NSString*)httpMethod returningResponse:(NSHTTPURLResponse**)response error:(NSError**)error;
+ (NSData*) sendRequestToURL:(NSString*)url withArgs:(NSDictionary*)args headers:(NSDictionary*)headers method:(NSString*)httpMethod returningResponse:(NSHTTPURLResponse**)response error:(NSError**)error;
+ (NSMutableURLRequest*) getURLRequestForPath:(NSString*)path args:(NSDictionary*)args method:(NSString*)httpMethod;
+ (NSMutableURLRequest*) getURLRequestForURL:(NSString*)url args:(NSDictionary*)args method:(NSString*)httpMethod useMultipart:(BOOL)multipart;
+ (NSString*) truncateString:(NSString*)string toLength:(int)length;
+ (void)zoomMapToFitAnnotations:(WDMapView*)mapView;
+ (NSString*) getLocalizedDateStringForDate:(NSDate*)date;
+ (void) showComingSoonAlert;
+ (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage;
+ (UIImage*) maskImage:(UIImage *)image andResizeMask:(UIImage *)maskImage;
+ (NSString*)timeIntervalStringWithStartDate:(NSDate*)d1 withEndDate:(NSDate*)d2;
+ (int) convertFloatToEvenInt:(CGFloat)float_num;
+ (NSDictionary *)parseURLParams:(NSString *)query;
+ (void) centerView:(UIView *)view horizontallyInView:(UIView*)view2;
+ (void) centerView:(UIView *)view verticallyInView:(UIView*)view2;
+ (void) centerView:(UIView*)view inView:(UIView*)view2;
+ (CGRect) centerRect:(CGRect)rect inRect:(CGRect)parentRect;
+ (NSDictionary*) getArgsDictionaryFromPOSTMethodsString:(NSString*)string;
+ (NSString*) sendRequestReturningStringToPath:(NSString*)path withArgs:(NSDictionary*) args method:(NSString*)httpMethod;

@end