//
//  AGModalView.m
//
//  Created by Andrei Gubceac on 11/10/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "AGModalView.h"

@implementation AGModalView

- (void)showAnimated:(BOOL)animated
{
    if (self.superview)
        return;
    UIWindow *_w = [[[UIApplication sharedApplication] windows] firstObject];
    UIView *_supportView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    _supportView.backgroundColor = [UIColor clearColor];
    [_w addSubview:_supportView];
    [_supportView addSubview:self];
    [self layoutSubviews];
        
    self.top = _supportView.bottom;
    if (animated)
    {
        _supportView.alpha = .0;
        [UIView animateWithDuration:.25 animations:^{
            _supportView.alpha = 1.;
            self.top = (_supportView.height-self.height);
        }];
    }
    else
        self.top = (_supportView.height-self.height);
}

- (void)hideAnimated:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:.25 animations:^{
            self.top = self.superview.bottom;
            self.superview.alpha = .0;
        } completion:^(BOOL finished) {
            [self.superview removeFromSuperview];
        }];
    }
    else
        [self.superview removeFromSuperview];
}

@end
