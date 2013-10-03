//
//  UIButton+Additions.m
//
//  Created by Andrei Gubceac on 12/11/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "UIButton+Additions.h"

@interface AGButtonToggle : UIButton
@property (nonatomic, copy) void(^actionBlock)(UIButton*, BOOL);
@end

@implementation AGButtonToggle

#pragma mark - private

- (void)toggleAction:(UIButton*)b
{
    b.selected = !b.selected;
    if (self.actionBlock)
        self.actionBlock(self,b.selected);
}

@end

@interface UIButton ()<NSCopying>
@property (nonatomic, copy) void(^actionBlock)(UIButton*, BOOL);
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

+ (UIButton*)buttonWithNormalImage:(NSString*)normalImage toggleImage:(NSString*)toggleImage actionBlock:(void(^)(UIButton*, BOOL))block
{
    AGButtonToggle *_b = (AGButtonToggle*)[UIButton buttonWithType:UIButtonTypeCustom actionBlock:block];
    [_b setImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
    [_b setImage:[UIImage imageNamed:toggleImage] forState:UIControlStateSelected];
    [_b setFrame:(CGRect){CGPointZero, [_b imageForState:UIControlStateNormal].size}];
    return _b;
}

+ (UIButton*)buttonWithType:(UIButtonType)buttonType actionBlock:(void(^)(UIButton*, BOOL))block;
{
    AGButtonToggle *_b    = [AGButtonToggle buttonWithType:buttonType];
    [_b addTarget:_b action:@selector(toggleAction:) forControlEvents:UIControlEventTouchUpInside];
    [_b setActionBlock:block];
    return _b;
}

@end
