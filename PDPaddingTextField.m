//
//  PDPaddingLabel.m
//  Eigooo
//
//  Created by Peter on 14/10/13.
//
//

#import "PDPaddingTextField.h"

@implementation PDPaddingTextField
@synthesize leftPadding;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.origin.x + self.leftPadding, bounds.origin.y,
                      bounds.size.width - self.leftPadding, bounds.size.height);
    
}
- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
