//
//  UITextField+Additions.m
//
//  Created by Andrei Gubceac on 12/24/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "UITextField+Additions.h"

@implementation UITextField (Additions)
- (BOOL)resignFirstResponderAndMoveToNextFieldWithDoneBlock:(void(^)(void))block
{
    [self resignFirstResponder];
    UIView *_nextTextField = [self.superview viewWithTag:self.tag+1];
    if (_nextTextField)
        [_nextTextField becomeFirstResponder];
    else if (block)
        block();
    return YES;
}
@end
