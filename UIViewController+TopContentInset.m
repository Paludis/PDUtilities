//
//  UIViewController+TopContentInset.m
//  Eigooo
//
//  Created by Peter on 15/05/14.
//
//

#import "UIViewController+TopContentInset.h"

@implementation UIViewController (TopContentInset)

- (CGFloat) getTopContentInset
{
    CGFloat topInset = 0.0f;
    if (self.navigationController.navigationBar.isTranslucent)
    {
        topInset += self.navigationController.navigationBar.frame.size.height;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        {
            CGRect frame = [[UIApplication sharedApplication] statusBarFrame];
            CGFloat statusBarHeight = MIN(frame.size.height, frame.size.width);
            topInset += statusBarHeight;
        }
    }
    return topInset;
}

@end
