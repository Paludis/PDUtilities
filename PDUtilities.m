//
//  Utilities.m
//  ios-common
//
//  Created by Peter Denniss on 8/03/11.
//  Copyright 2011 Go1 Pty Ltd. All rights reserved.
//

#import "PDUtilities.h"
#import <CommonCrypto/CommonHMAC.h>
#import "Common.h"
#import "Util.h"
#import "Serializer.h"

#ifndef SITE_URL
#define SITE_URL @""
#endif

#ifdef DEBUG
#	define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#	define DLog1(fmt, ...) {static __dlog1_once = true; if (__dlog1_once) { NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__); __dlog1_once = false; } }
#else
#	define DLog(...)
#	define DLog1(...)
#endif

#define DLogC(is_active,fmt, ...) {if (is_active) { DLog(fmt, ##__VA_ARGS__); } }

// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#ifdef UI_USER_INTERFACE_IDIOM
#define IS_IPAD() (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define _IPHONESDK3_2
#else
#define IS_IPAD() (false)
#endif

static PDUtilities* sharedInstance = nil;

@implementation PDUtilities


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

- (id) init
{
    alertTags = [NSMutableDictionary new];
    return self;
}

- (void) showConnectionError
{
    if (!alertShowing)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection Error", nil) message:NSLocalizedString(@"Could not connect to the server. Please check your internet connection and try again.", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.tag = kConnectionErrorTag;
        alert.delegate = self;
        [alert show];
        alertShowing = YES;
    }
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kConnectionErrorTag)
    {
        alertShowing = NO;
    }
    else
    {
        [alertTags setObject:[NSNumber numberWithBool:NO] forKey:[NSString stringWithFormat:@"%d", alertView.tag]];
    }
}

- (void) showAlertWithTitle:(NSString *)title message:(NSString *)message tag:(int)tag
{
    NSNumber* showingNum = [alertTags objectForKey:[NSString stringWithFormat:@"%d", tag]];
    
    BOOL showing;
    if (showingNum)
    {
        showing = [showingNum boolValue];
    }
    else
    {
        showing = NO;
    }
    if (!showing)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.tag = tag;
        [alert show];
        [alertTags setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%d", tag]];
    }
}

+ (PDUtilities*) sharedUtilities {
    @synchronized (self) {
        if (sharedInstance == nil){
            [self new];
        }
    }
    return sharedInstance;
}

+ (void)resizeFontForLabel:(UILabel*)aLabel maxSize:(int)maxSize minSize:(int)minSize {
    // use font from provided label so we don't lose color, style, etc
    UIFont *font = aLabel.font;
    
    // start with maxSize and keep reducing until it doesn't clip
    for(int i = maxSize; i > 10; i--) {
        font = [font fontWithSize:i];
        CGSize constraintSize = CGSizeMake(aLabel.frame.size.width, MAXFLOAT);
        
        // This step checks how tall the label would be with the desired font.
        CGSize labelSize = [aLabel.text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        if(labelSize.height <= aLabel.frame.size.height)
            break;
    }
    // Set the UILabel's font to the newly adjusted font.
    aLabel.font = font;
}

//generate md5 hash from string
+ (NSString *) returnMD5Hash:(NSString*)concat {
    const char *concat_str = [concat UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(concat_str, strlen(concat_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
    
}


+ (NSString*) getFilePathForFileInDocumentsDirectory:(NSString*)filename{
    
    NSString* docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* filepath = [docsPath stringByAppendingPathComponent:filename];
    return filepath;
}

+ (NSData*) sendRequestToPath:(NSString*)path withArgs:(NSDictionary*)args method:(NSString*)httpMethod
{

    NSURLRequest* request = [self getURLRequestForURL:path args:args method:httpMethod];
    
    DLog(@"request URL: %@", request.URL.absoluteString);
    
    NSData* urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    return urlData;
}

+ (NSData*) sendRequestToURL:(NSString*)url withArgs:(NSDictionary*)args method:(NSString*)httpMethod returningResponse:(NSHTTPURLResponse**)response error:(NSError**)error
{
    return [self sendRequestToURL:url withArgs:args headers:nil method:httpMethod returningResponse:response error:error];
}

+ (NSData*) sendRequestToURL:(NSString*)url withArgs:(NSDictionary*)args headers:(NSDictionary*)headers method:(NSString*)httpMethod returningResponse:(NSHTTPURLResponse**)response error:(NSError**)error
{
    NSMutableURLRequest* request = [[self getURLRequestForURL:url args:args method:httpMethod useMultipart:NO] mutableCopy];
    for (NSString* key in [headers allKeys])
    {
        [request addValue:[headers objectForKey:key] forHTTPHeaderField:key];
    }
    NSData* urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:response error:error];
    return urlData;
}

+ (NSMutableURLRequest*) getURLRequestForURL:(NSString*)url args:(NSDictionary*)args method:(NSString*)httpMethod useMultipart:(BOOL)multipart
{
    if ([httpMethod isEqualToString:@"GET"])
    {
        NSString* getBody = [[self getPOSTMethodsStringFromDictionary:args] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        url = [url stringByAppendingFormat:@"?%@", getBody];
    }
    
#ifdef _GSREQUESTCOMMS
	DLog(@"request URL: %@", url);
#endif // _COMMSTRACE
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:30];
    
#ifdef _GSREQUESTCOMMS
    DLog(@"request args: %@", args);
#endif // _COMMSTRACE
    
    if (IS_IPAD()){
        [request setValue:@"Mozilla/5.0 (iPad; U; CPU iOS 2_0 like Mac OS X; en-us) AppleWebKit/525.18.1 (KHTML, like Gecko) Version/3.1.1 Mobile/XXXXX Safari/525.20" forHTTPHeaderField:@"User-Agent"];
    } else
    {
        [request setValue:@"Mozilla/5.0 (iPhone; U; CPU iOS 2_0 like Mac OS X; en-us) AppleWebKit/525.18.1 (KHTML, like Gecko) Version/3.1.1 Mobile/XXXXX Safari/525.20" forHTTPHeaderField:@"User-Agent"];
    }
    
#ifdef _GSREQUESTCOMMS
    DLog(@"request is %@", httpMethod);
#endif // _COMMSTRACE
    [request setHTTPMethod:httpMethod];
    if (args && multipart)
    {
//        NSData* reqData = [WDTransfer dataForMultipartPOSTWithDictionary:args boundary:@"_gpslog-42398453985984598452_"];
//        [request addValue: @"multipart/form-data; boundary=_gpslog-42398453985984598452_" forHTTPHeaderField: @"Content-Type"];
//        [request setValue:[NSString stringWithFormat:@"%i", [reqData length]] forHTTPHeaderField:@"Content-Length"];
//        [request setHTTPBody:reqData];
    }
    else if (![httpMethod isEqualToString:@"GET"])
    {
        NSString* postbody = [[self getPOSTMethodsStringFromDictionary:args] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#ifdef _GSREQUESTCOMMS
        DLog(@"HTTP Body: %@", postbody);
#endif // _COMMSTRACE
        [request setHTTPBody:[postbody dataUsingEncoding:NSUTF8StringEncoding]];
    }
    return request;
}

+ (NSMutableURLRequest*) getURLRequestForURL:(NSString*)path args:(NSDictionary*)args method:(NSString*)httpMethod {
    
    //NSString* fullURL = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [self getURLRequestForURL:path args:args method:httpMethod useMultipart:NO];
}

+ (NSString*) sendRequestReturningStringToPath:(NSString*)path withArgs:(NSDictionary*) args method:(NSString*)httpMethod
{
    NSData* data = [self sendRequestToPath:path withArgs:args method:httpMethod];
    NSString* response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return response;
}

+ (NSString*) sendRequestReturningStringToPath:(NSString*)path withArgs:(NSDictionary*) args
{
    return [self sendRequestReturningStringToPath:path withArgs:args method:@"POST"];
}

+ (NSDictionary*) getArgsDictionaryFromPOSTMethodsString:(NSString*)string
{
    NSMutableDictionary* dict = [NSMutableDictionary new];
    NSArray* array = [string componentsSeparatedByString:@"&"];
    for (NSString* string in array)
    {
        NSArray* components = [string componentsSeparatedByString:@"="];
        if (components.count == 2)
        {
            NSString* key = [components objectAtIndex:0];
            NSString* value = [components objectAtIndex:1];
            [dict setObject:value forKey:key];
        }
    }
    return dict;
}

+ (NSString*) getPOSTMethodsStringFromDictionary:(NSDictionary*)dictionary {
    
    NSString* methodsString = @"";
    
    if (dictionary){
                        
        NSString* ampersand = @"";      // start off blank because we don't want an ampersand at the start.

        for (NSString* key in [dictionary allKeys])
        {
            id value = [dictionary objectForKey:key];
            if ([value isKindOfClass:[NSString class]])
            {
                methodsString = [methodsString stringByAppendingFormat:@"%@%@=%@", ampersand, key, value];
            }
            else if ([value isKindOfClass:[NSDictionary class]])
            {
                //for nested params
                for (NSString* paramKey in [value allKeys])
                {
                    methodsString = [methodsString stringByAppendingFormat:@"%@%@[%@]=%@", ampersand, key, paramKey, [value objectForKey:paramKey]];
                    ampersand = @"&";
                }
            }
            ampersand = @"&";
        }
    }

    return methodsString;
}

//ref: https://github.com/workhabitinc/drupal-ios-sdk/blob/7.x-3.x/DIOSConnect.m
+ (NSString *)generateSHA256Hash:(NSString *)inputString usingKey:(NSString*)key {
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData = [inputString dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH] = {0};
    CCHmacContext hmacContext;
    CCHmacInit(&hmacContext, kCCHmacAlgSHA256, keyData.bytes, keyData.length);
    CCHmacUpdate(&hmacContext, clearTextData.bytes, clearTextData.length);
    CCHmacFinal(&hmacContext, digest);
    NSData *hashedData = [NSData dataWithBytes:digest length:32];
    NSString *hashedString = [self stringWithHexBytes:hashedData];
    ////DLog(@"hash string: %@ length: %d",[hashedString lowercaseString],[hashedString length]);
    return [hashedString lowercaseString];
}

//ref: https://github.com/workhabitinc/drupal-ios-sdk/blob/7.x-3.x/DIOSConnect.m
+ (NSString*)stringWithHexBytes:(NSData *)theData {
    NSMutableString *stringBuffer = [NSMutableString stringWithCapacity:([theData length] * 2)];
    const unsigned char *dataBuffer = [theData bytes];
    int i;
    
    for (i = 0; i < [theData length]; ++i)
        [stringBuffer appendFormat:@"%02lX", (unsigned long)dataBuffer[ i ]];
    
    return [stringBuffer copy];
}

//ref: https://github.com/workhabitinc/drupal-ios-sdk/blob/7.x-3.x/DIOSConnect.m
+ (NSString *) genRandStringLength {	
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: 10];
    for (int i=0; i<10; i++) {
        [randomString appendFormat: @"%c", [letters characterAtIndex: arc4random()%[letters length]]];
    }
    return randomString;
}

+ (void) showAlertWithTitle:(NSString*)title message:(NSString*)message{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

+ (void) showConnectionError{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Could not connect to the server. Please check your internet connection and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

+ (UIColor *) colorWithHexString: (NSString *) stringToConvert{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor blackColor];
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString length] != 6) return [UIColor blackColor];
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

+ (void) clearCookies {
    NSHTTPCookieStorage* cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie* cookie in [cookieJar cookies]){
        [cookieJar deleteCookie:cookie];
    }
}

+ (UIImage*)imageByScalingAndCroppingImage:(UIImage*)image forSize:(CGSize)targetSize{
    
    UIImage *sourceImage = image;
    UIImage *newImage = nil;        
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) 
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor) 
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
        }
        else 
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }       
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) 
        NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
    
}

//ref : http://stackoverflow.com/a/11270639/645697
+ (NSString*)getYoutubeEmbedCodeForVideoID:(NSString*)videoID size:(CGSize)size
{
    NSString* embedHTML = @"\
    <object>\
    <param name=\"movie\" value=\"http://www.youtube.com/v/%@\"></param>\
    <embed class=\"player\" src=\"http://www.youtube.com/v/%@\" type=\"application/x-shockwave-flash\" width=%d height=%d></embed>\
    </object>\
    <style>\
        body{\
            margin:0px;\
        }\
    </style>";
    NSString* html = [NSString stringWithFormat:embedHTML, videoID, videoID, (int)size.width, (int)size.height];
    DLog(@"youtube html: %@", html);
    return html;
}  

+ (BOOL) string:(NSString*)string1 containsString:(NSString*)substring {
    
    NSRange textRange;
    textRange =[[string1 lowercaseString] rangeOfString:[substring lowercaseString]];
    
    if(textRange.location != NSNotFound)
    {
        return TRUE;
        
    } else {
        return FALSE;
    }
}

- (void) showNetworkIndicator:(BOOL)on{
    
    if (on){
        indicatorCount++;
    } else {
        indicatorCount--;
    }
    
    [self changeNetworkIndicator];
    
}

- (void) changeNetworkIndicator{
    if (indicatorCount <= 0){
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}

+ (BOOL) isPortrait {
    /*if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown){
        return YES;
    } else {
        return NO;
    }*/
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait ||  [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown){
        return YES;
    } else {
        return NO;
    }
}

+ (NSString*) truncateString:(NSString*)string toLength:(int)length{
    
    NSRange stringRange = {0, MIN(string.length, length)};
    NSString* shortString = [string substringWithRange:stringRange];
    
    if (shortString.length < string.length){
        // if it's been shortened, add '...'
        return [NSString stringWithFormat:@"%@...", shortString];
    } else {
        return shortString; 
    }
}


+ (NSString*) getLocalizedDateStringForDate:(NSDate*)date
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    NSString *dateComponents = @"yyyyMMdd";
    NSString *format = [NSDateFormatter dateFormatFromTemplate:dateComponents options:0 locale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:date];
}

+ (void) showComingSoonAlert
{
    [self showAlertWithTitle:@"Coming Soon!" message:@"This feature will be in the beta soon."];
}

CGImageRef CopyImageAndAddAlphaChannel(CGImageRef sourceImage) {
	CGImageRef retVal = NULL;
	
	size_t width = CGImageGetWidth(sourceImage);
	size_t height = CGImageGetHeight(sourceImage);
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	CGContextRef offscreenContext = CGBitmapContextCreate(NULL, width, height, 
                                                          8, 0, colorSpace, kCGImageAlphaPremultipliedFirst);
	
	if (offscreenContext != NULL) {
		CGContextDrawImage(offscreenContext, CGRectMake(0, 0, width, height), sourceImage);
		
		retVal = CGBitmapContextCreateImage(offscreenContext);
		CGContextRelease(offscreenContext);
	}
	
	CGColorSpaceRelease(colorSpace);
	
	return retVal;
}

//Constants
#define SECOND 1
#define MINUTE (60 * SECOND)
#define HOUR (60 * MINUTE)
#define DAY (24 * HOUR)
#define MONTH (30 * DAY)

+ (NSString*)timeIntervalStringWithStartDate:(NSDate*)d1 withEndDate:(NSDate*)d2
{
    //Calculate the delta in seconds between the two dates
    NSTimeInterval delta = [d2 timeIntervalSinceDate:d1];
    
    if (delta < 1 * MINUTE)
    {
        return delta == 1 ? NSLocalizedString(@"a second ago", nil) : [NSString stringWithFormat:NSLocalizedString(@"%d seconds ago", nil), (int)delta];
    }
    if (delta < 2 * MINUTE)
    {
        return NSLocalizedString(@"a minute ago", nil);
    }
    if (delta < 45 * MINUTE)
    {
        int minutes = floor((double)delta/MINUTE);
        return [NSString stringWithFormat:NSLocalizedString(@"%d minutes ago", nil), minutes];
    }
    if (delta < 120 * MINUTE)
    {
        return NSLocalizedString(@"an hour ago", nil);
    }
    if (delta < 24 * HOUR)
    {
        int hours = floor((double)delta/HOUR);
        return [NSString stringWithFormat:NSLocalizedString(@"%d hours ago", nil), hours];
    }
    if (delta < 48 * HOUR)
    {
        return NSLocalizedString(@"yesterday", nil);
    }
    if (delta < 30 * DAY)
    {
        int days = floor((double)delta/DAY);
        return [NSString stringWithFormat:NSLocalizedString(@"%d days ago", nil), days];
    }
    if (delta < 12 * MONTH)
    {
        int months = floor((double)delta/MONTH);
        return months <= 1 ? NSLocalizedString(@"a month ago", nil) : [NSString stringWithFormat:NSLocalizedString(@"%d months ago", nil), months];
    }
    else
    {
        int years = floor((double)delta/MONTH/12.0);
        return years <= 1 ? NSLocalizedString(@"a year ago", nil) : [NSString stringWithFormat:NSLocalizedString(@"%d years ago", nil), years];
    }
}

+ (int) convertFloatToEvenInt:(CGFloat)float_num
{
    
    int int_num = (int)float_num;
    
    // make sure it's divisible by 2 (for retina pixel halving)
    if (int_num % 2 == 0)
    {
        return int_num;
    }
    else
    {
        return int_num + 1;
    }
}

/**
 * Helper method to parse URL query parameters
 */
+ (NSDictionary *)parseURLParams:(NSString *)query {
	NSArray *pairs = [query componentsSeparatedByString:@"&"];
	NSMutableDictionary *params = [NSMutableDictionary new];
	for (NSString *pair in pairs) {
		NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString* val = @"";
        
        if (kv.count > 1)
        {
            val = [[kv objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        
        /// THIS IS IN CASE FACEBOOK DOESN'T ESCAPE THE URL PROPERLY BECUASE THEY ARE FUCKING IDIOTS.. AS OF MARCH 7 2013 THEY SEND TARGET_URL UNESCAPED
        if (kv.count > 2)
        {
            // have more than one '='.. caused by case like 'target_url=asdf?q=asd' with an unescaped URL....
            int count = 0;
            for (NSString* string in kv)
            {
                if (count > 1)
                {
                    val = [[val stringByAppendingFormat:@"=%@", string] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                }
                count++;
            }
        }
        ///

        if (kv.count > 1)
        {
            [params setObject:val forKey:[kv objectAtIndex:0]];
        }
	}
    return params;
}

+ (CGRect) centerRect:(CGRect)rect horizontallyInRect:(CGRect)parentRect
{
    rect.origin.x = parentRect.size.width / 2 - rect.size.width / 2;
    return rect;
}

+ (CGRect) centerRect:(CGRect)rect verticallyInRect:(CGRect)parentRect
{
    rect.origin.y = parentRect.size.height / 2 - rect.size.height / 2;
    return rect;
}

+ (void) centerView:(UIView *)view horizontallyInFrame:(CGRect)frame
{
    CGRect newFrame = [self centerRect:view.frame horizontallyInRect:frame];
    view.frame = newFrame;
}

+ (void) centerView:(UIView *)view verticallyInFrame:(CGRect)frame
{
    CGRect newFrame = [self centerRect:view.frame verticallyInRect:frame];
    view.frame = newFrame;
}

+ (void) centerView:(UIView*)view inFrame:(CGRect)frame
{
    [self centerView:view horizontallyInFrame:frame];
    [self centerView:view verticallyInFrame:frame];
}

+ (void) centerView:(UIView *)view horizontallyInView:(UIView*)view2
{
    CGRect newFrame = [self centerRect:view.frame horizontallyInRect:view2.frame];
    view.frame = newFrame;
}

+ (void) centerView:(UIView *)view verticallyInView:(UIView*)view2
{
    CGRect newFrame = [self centerRect:view.frame verticallyInRect:view2.frame];
    view.frame = newFrame;
}

+ (void) centerView:(UIView*)view inView:(UIView*)view2
{
    [self centerView:view horizontallyInView:view2];
    [self centerView:view verticallyInView:view2];
}

+ (CGRect) centerRect:(CGRect)rect inRect:(CGRect)parentRect
{
    CGRect horizontallyCenteredRect = [self centerRect:rect horizontallyInRect:parentRect];
    CGRect centeredRect = [self centerRect:horizontallyCenteredRect verticallyInRect:parentRect];
    return centeredRect;
}

+ (NSError*) errorWithCode:(int)code title:(NSString*)title message:(NSString*)message
{
    NSMutableDictionary* errorInfo = [NSMutableDictionary new];
    [errorInfo setObject:title forKey:NSLocalizedFailureReasonErrorKey];
    [errorInfo setObject:message forKey:NSLocalizedDescriptionKey];
    return [[NSError alloc] initWithDomain:kStandardErrorDomain code:code userInfo:errorInfo];
}

@end
