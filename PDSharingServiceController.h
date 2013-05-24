//
//  PDSharingServiceController.h
//  zedalert
//
//  Created by Peter Denniss on 26/10/11.
//  Copyright (c) 2011 GO1 Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Spike;

@interface PDSharingServiceController : NSObject {
    
    UIViewController* parentController;
    
}

- (id) initWithParentController:(UIViewController*)parentController;
- (void)shareSpike:(Spike*)spike;

@property (nonatomic, retain) UIViewController* parentController;

@end
