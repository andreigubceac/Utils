//
//  AGRevealViewController.h
//
//  Created by Andrei Gubceac on 1/29/13.
//  Copyright (c) 2013. All rights reserved.
//

#import <UIKit/UIKit.h>

extern float kOffsetX;
extern NSString *kAGRevealViewControllerWillRevealNotification, *kAGRevealViewControllerDidRevealNotification;
extern NSString *kAGRevealViewControllerWillCoverNotification, *kAGRevealViewControllerDidCoverNotification;

@interface AGRevealViewController : UIViewController
@property (nonatomic, strong) UIViewController *leftViewController, *centerViewController, *rightViewController;
@property (nonatomic) BOOL disableLeftReveal, disableRightReveal;
@property (nonatomic, readonly) UIPanGestureRecognizer *panGesture;

- (id)initWithLeftViewController:(UIViewController*)leftViewController
             rightViewController:(UIViewController*)rightViewController centerViewController:(UIViewController*)centerViewController;

- (void)toggleLeftSideAnimated:(BOOL)animated completeBlock:(void(^)(void))block;
- (void)toggleRightSideAnimated:(BOOL)animated completeBlock:(void(^)(void))block;;
- (void)closeLeftSideAnimated:(BOOL)animated completeBlock:(void(^)(void))block;;
- (void)closeRightSideAnimated:(BOOL)animated completeBlock:(void(^)(void))block;;

- (UIBarButtonItem*)leftItemWithButton:(UIButton*)button;
- (UIBarButtonItem*)rightItemWithButton:(UIButton*)button;

- (void)panGestureAction:(UIPanGestureRecognizer*)g;//subclass
@end
