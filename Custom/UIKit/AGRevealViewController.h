//
//  AGRevealViewController.h
//
//  Created by Andrei Gubceac on 1/29/13.
//  Copyright (c) 2013. All rights reserved.
//

#import <UIKit/UIKit.h>

extern float kOffsetX;
extern NSString *_Null_unspecified kAGRevealViewControllerWillRevealNotification, *_Null_unspecified kAGRevealViewControllerDidRevealNotification;
extern NSString *_Null_unspecified kAGRevealViewControllerWillCoverNotification, *_Null_unspecified kAGRevealViewControllerDidCoverNotification;

@interface AGRevealViewController : UIViewController
@property (nullable, nonatomic, strong) UIViewController *leftViewController, *rightViewController;
@property (nonnull, nonatomic, strong) UIViewController *centerViewController;
@property (nonatomic) BOOL disableLeftReveal, disableRightReveal;
@property (nonnull, nonatomic, readonly) UIPanGestureRecognizer *panGesture;

- (nonnull id)initWithLeftViewController:(nullable UIViewController*)leftViewController
             rightViewController:(nullable UIViewController*)rightViewController centerViewController:(nonnull UIViewController*)centerViewController;

- (void)toggleLeftSideAnimated:(BOOL)animated completeBlock:(nullable void(^)(void))block;
- (void)toggleRightSideAnimated:(BOOL)animated completeBlock:(nullable void(^)(void))block;;
- (void)closeLeftSideAnimated:(BOOL)animated completeBlock:(nullable void(^)(void))block;;
- (void)closeRightSideAnimated:(BOOL)animated completeBlock:(nullable void(^)(void))block;;

- (nonnull UIBarButtonItem*)leftItemWithButton:(nonnull UIButton*)button;
- (nonnull UIBarButtonItem*)rightItemWithButton:(nonnull UIButton*)button;

- (void)panGestureAction:(nonnull UIPanGestureRecognizer*)g;//subclass
@end
