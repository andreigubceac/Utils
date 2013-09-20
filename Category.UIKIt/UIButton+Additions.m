//
//  UIButton+Additions.m
//
//  Created by Andrei Gubceac on 12/11/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "UIButton+Additions.h"

@interface UIButton ()<NSCopying>
@end

@implementation UIButton (Additions)
- (id)copy
{
    UIButton *b = [UIButton buttonWithType:self.buttonType];
    [b setImage:[self imageForState:UIControlStateNormal] forState:UIControlStateNormal];
    [b setImage:[self imageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [b setBackgroundImage:[self backgroundImageForState:UIControlStateNormal] forState:UIControlStateNormal];
    [b setBackgroundImage:[self backgroundImageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [b setTitleColor:[self titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
    [b setTitleColor:[self titleColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [b setFrame: self.frame];
    [b setTitleEdgeInsets:self.titleEdgeInsets];
    [b setContentEdgeInsets:self.contentEdgeInsets];
    [b.titleLabel setFont:self.titleLabel.font];
    return b;
}

@end
