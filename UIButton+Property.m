//
//  UIButton+Property.m
//  uDelivered
//
//  Created by Peter on 3/09/13.
//
//

// ref: http://stackoverflow.com/a/5500525/645697

#import "UIButton+Property.h"
#import <objc/runtime.h>

@implementation UIButton(Property)

static char UIB_PROPERTY_KEY;

@dynamic property;

-(void)setProperty:(NSObject *)property
{
    objc_setAssociatedObject(self, &UIB_PROPERTY_KEY, property, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSObject*)property
{
    return (NSObject*)objc_getAssociatedObject(self, &UIB_PROPERTY_KEY);
}

@end