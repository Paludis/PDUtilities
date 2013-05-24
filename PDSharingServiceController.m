//
//  PDSharingServiceController.m
//  zedalert
//
//  Created by Peter Denniss on 26/10/11.
//  Copyright (c) 2011 GO1 Pty Ltd. All rights reserved.
//

#import "PDSharingServiceController.h"

@implementation PDSharingServiceController 

@synthesize parentController;

- (id) initWithParentController:(UIViewController*)m_parentController
{
    self.parentController = m_parentController;
    return self;
}

- (void) shareSpike:(Spike *)spike
{
    // implement in subclass
}

@end
