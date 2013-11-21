//
//  AGRevealViewController.m
//
//  Created by Andrei Gubceac on 1/29/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "AGRevealViewController.h"
#import <QuartzCore/QuartzCore.h>

float kOffsetX = 60;
const CGFloat kSlideAnimationDuration = .3;

NSString *kAGRevealViewControllerWillRevealNotification = @"kAGRevealViewControllerWillRevealNotification", *kAGRevealViewControllerDidRevealNotification = @"kAGRevealViewControllerDidRevealNotification";
NSString *kAGRevealViewControllerWillCoverNotification = @"kAGRevealViewControllerWillCoverNotification", *kAGRevealViewControllerDidCoverNotification = @"kAGRevealViewControllerDidCoverNotification";

@interface AGRevealViewController ()
{
    UIView *_noUserInteractionView;
    UIButton *_leftItem, *_rightItem;
    UIPanGestureRecognizer *_panGesture;
}
- (void)panGestureAction:(UIPanGestureRecognizer*)g;
@end

@implementation AGRevealViewController
@synthesize panGesture = _panGesture;

- (id)initWithLeftViewController:(UIViewController*)leftViewController rightViewController:(UIViewController*)rightViewController centerViewController:(UIViewController*)centerViewController
{
    self = [super init];
    if (self)
    {
        _disableLeftReveal = _disableRightReveal = NO;
        _leftViewController     = leftViewController;
        _centerViewController   = centerViewController;
        _rightViewController    = rightViewController;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setLeftViewController:_leftViewController];
    [self setRightViewController:_rightViewController];
    [self setCenterViewController:_centerViewController];
    _leftViewController.view.hidden = _rightViewController.view.hidden = YES;
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    [self.view addGestureRecognizer:_panGesture];
}

- (void)applyTransfromToDirection:(int)direction animated:(BOOL)animated completeBlock:(void(^)(void))block
{
    void (^applyTransformBlock)() = ^{
        _centerViewController.view.transform = CGAffineTransformMakeTranslation(direction * (CGRectGetWidth(_centerViewController.view.frame)-kOffsetX), 0);
        
        if ([self isLeftSideDisplayed])
            [self.view insertSubview:_leftViewController.view aboveSubview:_rightViewController.view];
        else if ([self isRightSideDisplayed])
            [self.view insertSubview:_rightViewController.view aboveSubview:_leftViewController.view];
        
        if ([_leftItem respondsToSelector:@selector(setSelected:)])
            _leftItem.selected = NO;
        if ([_rightItem respondsToSelector:@selector(setSelected:)])
            _rightItem.selected = NO;
        if (direction != 0)
        {
            UIView *_centerView = nil;
            if ([_centerViewController isKindOfClass:[UINavigationController class]])
            {
                _centerView = ((UINavigationController*)_centerViewController).topViewController.view;
                _leftItem   = (UIButton*)((UINavigationController*)_centerViewController).topViewController.navigationItem.leftBarButtonItem.customView;
                _rightItem  = (UIButton*)((UINavigationController*)_centerViewController).topViewController.navigationItem.rightBarButtonItem.customView;
            }
            else
            {
                _centerView = _centerViewController.view;
                _leftItem   = (UIButton*)_centerViewController.navigationItem.leftBarButtonItem.customView;
                _rightItem  = (UIButton*)_centerViewController.navigationItem.rightBarButtonItem.customView;
            }
            if ([_leftItem respondsToSelector:@selector(setSelected:)])
                _leftItem.selected = YES;
            if ([_rightItem respondsToSelector:@selector(setSelected:)])
                _rightItem.selected = YES;
            
            
            if (nil == _noUserInteractionView)
            {
                _noUserInteractionView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
                [_centerViewController.view addSubview:_noUserInteractionView];
                [_noUserInteractionView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAction:)]];
                [self.view removeGestureRecognizer:_panGesture];
                [_noUserInteractionView addGestureRecognizer:_panGesture];
                if ([_centerView isKindOfClass:[UIScrollView class]])
                    [(UIScrollView*)_centerView setScrollEnabled:NO];
            }
        }
        else if (_noUserInteractionView)
        {
            if ([_noUserInteractionView.superview isKindOfClass:[UIScrollView class]])
                [(UIScrollView*)_noUserInteractionView.superview setScrollEnabled:YES];
            [_noUserInteractionView removeGestureRecognizer:_panGesture];
            [self.view addGestureRecognizer:_panGesture];
            [_noUserInteractionView removeFromSuperview];
            _noUserInteractionView = nil;
        }
    };
    if (direction != 0)
        [[NSNotificationCenter defaultCenter] postNotificationName:kAGRevealViewControllerWillRevealNotification object:nil];
    else
        [[NSNotificationCenter defaultCenter] postNotificationName:kAGRevealViewControllerWillCoverNotification object:nil];
    _leftViewController.view.hidden = _rightViewController.view.hidden = NO;
    if (animated == NO)
    {
        applyTransformBlock();
        if (block)block();
        if (direction != 0)
            [[NSNotificationCenter defaultCenter] postNotificationName:kAGRevealViewControllerWillCoverNotification object:nil];
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kAGRevealViewControllerDidCoverNotification object:nil];
            _leftViewController.view.hidden = _rightViewController.view.hidden = YES;
        }
    }
    else
    {
        self.view.userInteractionEnabled = NO;
        [UIView animateWithDuration:kSlideAnimationDuration animations:applyTransformBlock completion:^(BOOL finished) {
            self.view.userInteractionEnabled = YES;
            if (block)
                block();
            if (direction != 0)
                [[NSNotificationCenter defaultCenter] postNotificationName:kAGRevealViewControllerDidRevealNotification object:nil];
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kAGRevealViewControllerDidCoverNotification object:nil];
                _leftViewController.view.hidden = _rightViewController.view.hidden = YES;
            }
        }];
    }
}

- (void)panGestureAction:(UIPanGestureRecognizer*)g
{
    if (UIGestureRecognizerStateBegan == g.state)
    {
        self.view.userInteractionEnabled = NO;
    }
    else if (UIGestureRecognizerStateChanged == g.state)
    {
        CGPoint pt = [g translationInView:g.view];
        if (_noUserInteractionView.superview)
        {
            if ([self isLeftSideDisplayed])
            {
                if (pt.x<0)
                    _centerViewController.view.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(_centerViewController.view.frame)-kOffsetX+pt.x, 0);
            }
            else if ([self isRightSideDisplayed])
            {
                if (pt.x>0)
                    _centerViewController.view.transform = CGAffineTransformMakeTranslation(-CGRectGetWidth(_centerViewController.view.frame)+kOffsetX+pt.x, 0);
            }
        }
        else
        {
            if (pt.x<0)
            {
                if (_rightViewController && !self.disableRightReveal)
                {
                    _rightViewController.view.hidden = NO;
                    [self.view insertSubview:_rightViewController.view aboveSubview:_leftViewController.view];
                    _centerViewController.view.transform = CGAffineTransformMakeTranslation(pt.x, 0);
                }
            }
            else if (pt.x>0)
            {
                if (_leftViewController && !self.disableLeftReveal)
                {
                    _leftViewController.view.hidden = NO;
                    [self.view insertSubview:_leftViewController.view aboveSubview:_rightViewController.view];
                    _centerViewController.view.transform = CGAffineTransformMakeTranslation(pt.x, 0);
                }
            }
        }
    }
    else
    {
        self.view.userInteractionEnabled = YES;
        int d = 0;
        if ([self isLeftSideDisplayed])
            d = _centerViewController.view.transform.tx <= CGRectGetWidth(self.view.frame)/2?0:1;
        else if ([self isRightSideDisplayed])
            d = _centerViewController.view.transform.tx >= -CGRectGetWidth(self.view.frame)/2?0:-1;
        
        [self applyTransfromToDirection:d animated:YES completeBlock:nil];
    }
}

- (void)closeAction:(UITapGestureRecognizer*)g
{
    if (UIGestureRecognizerStateEnded == g.state)
    {
        [self applyTransfromToDirection:0 animated:YES completeBlock:nil];
    }
}

- (BOOL)isLeftSideDisplayed
{
    return (_centerViewController.view.transform.tx>0 && _leftViewController != nil);
}

- (BOOL)isRightSideDisplayed
{
    return (_centerViewController.view.transform.tx<0 && _rightViewController != nil);
}

- (BOOL)isCenterSideDisplayed
{
    return (_centerViewController.view.transform.tx==0);
}

- (void)toggleLeftSide:(id)s
{
    [self toggleLeftSideAnimated:YES completeBlock:nil];
}

- (void)toggleRightSide:(id)s
{
    [self toggleRightSideAnimated:YES completeBlock:nil];
}
#pragma mark - public

- (void)setRightViewController:(UIViewController *)rightViewController_
{
    [_rightViewController viewWillDisappear:NO];
    [_rightViewController.view removeFromSuperview];
    [_rightViewController viewDidDisappear:NO];
    [_rightViewController removeFromParentViewController];
    _rightViewController = rightViewController_;
    if (nil == _rightViewController)
        return;
    
    [self.view insertSubview:_rightViewController.view atIndex:0];
    [self addChildViewController:_rightViewController];
    [_rightViewController.view setFrame:self.view.bounds];
    CGRect _frame = self.view.bounds;
    _frame.size.width -= kOffsetX;
    _frame.origin.x = kOffsetX;
    [_rightViewController.view setFrame:_frame];
    UINavigationBar *_navBar = ((UINavigationController*)_rightViewController).navigationBar;
    if (_navBar == nil)
        _navBar = _rightViewController.navigationController.navigationBar;
    _navBar.frame = _navBar.bounds;
}

- (void)setLeftViewController:(UIViewController *)leftViewController_
{
    [_leftViewController viewWillDisappear:NO];
    [_leftViewController.view removeFromSuperview];
    [_leftViewController viewDidDisappear:NO];
    [_leftViewController removeFromParentViewController];
    _leftViewController = leftViewController_;
    if (nil == _leftViewController)
        return;
    [self addChildViewController:_leftViewController];
    [self.view insertSubview:_leftViewController.view atIndex:1];
    CGRect _frame = self.view.bounds;
    _frame.size.width -= kOffsetX;
    [_leftViewController.view setFrame:_frame];
}

- (void)setCenterViewController:(UIViewController *)centerViewController_
{
    [_centerViewController viewWillDisappear:NO];
    [_centerViewController.view removeFromSuperview];
    [_centerViewController removeFromParentViewController];
    [_centerViewController viewDidDisappear:NO];
    
    _centerViewController = centerViewController_;
    NSAssert(_centerViewController!=nil, @"The front view Controller is NULL");
    [_centerViewController viewWillAppear:NO];
    [self.view addSubview:centerViewController_.view];
    [self addChildViewController:_centerViewController];
    [_centerViewController viewDidAppear:NO];
    [_centerViewController.view setFrame:self.view.bounds];
    _centerViewController.view.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:.5].CGColor;
    _centerViewController.view.layer.shadowOpacity = .5;
    UIBezierPath *_shadowPath = [UIBezierPath bezierPathWithRect:(CGRect){{-10,0},{CGRectGetWidth(_centerViewController.view.frame)+20,CGRectGetHeight(_centerViewController.view.frame)}}];
    _centerViewController.view.layer.shadowPath = _shadowPath.CGPath;
}

- (void)toggleLeftSideAnimated:(BOOL)animated completeBlock:(void(^)(void))block
{
    if ([self isRightSideDisplayed])
        [self applyTransfromToDirection:0 animated:animated completeBlock:^{
            [self applyTransfromToDirection:1 animated:animated completeBlock:block];
        }];
    else if ([self isLeftSideDisplayed])
        [self applyTransfromToDirection:0 animated:animated completeBlock:block];
    else
        [self applyTransfromToDirection:1 animated:animated completeBlock:block];
}

- (void)toggleRightSideAnimated:(BOOL)animated completeBlock:(void(^)(void))block
{
    if ([self isLeftSideDisplayed])
        [self applyTransfromToDirection:0 animated:animated completeBlock:^{
            [self applyTransfromToDirection:-1 animated:animated completeBlock:block];
        }];
    else if ([self isRightSideDisplayed])
        [self applyTransfromToDirection:0 animated:animated completeBlock:block];
    else
        [self applyTransfromToDirection:-1 animated:animated completeBlock:block];
}

- (void)closeLeftSideAnimated:(BOOL)animated completeBlock:(void(^)(void))block;
{
    if ([self isLeftSideDisplayed])
        [self applyTransfromToDirection:0 animated:animated completeBlock:block];
    else if (block)
        block();
}

- (void)closeRightSideAnimated:(BOOL)animated completeBlock:(void(^)(void))block;
{
    if ([self isRightSideDisplayed])
        [self applyTransfromToDirection:0 animated:animated completeBlock:block];
    else if (block)
        block();
}

- (UIBarButtonItem*)leftItemWithButton:(UIButton*)button
{
    UIBarButtonItem *_b = [[UIBarButtonItem alloc] initWithCustomView:button];
    [button addTarget:self action:@selector(toggleLeftSide:) forControlEvents:UIControlEventTouchUpInside];
    return _b;
}

- (UIBarButtonItem*)rightItemWithButton:(UIButton*)button
{
    UIBarButtonItem *_b = [[UIBarButtonItem alloc] initWithCustomView:button];
    [button addTarget:self action:@selector(toggleRightSide:) forControlEvents:UIControlEventTouchUpInside];
    return _b;
}

@end
