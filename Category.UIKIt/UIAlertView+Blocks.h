//
//  UIAlertView+Blocks.h
//
//  Created by Andrei Gubceac on 4/25/13.
//  Copyright (c) 2013 -. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (Blocks)
+ (UIAlertView*)alertViewWithTitle:(NSString*)title message:(NSString*)message cancelButtonTitle:(NSString*)cancelTitle
                       actionBlock:(void(^)(UIAlertView*, NSInteger))block otherButtonTitles:(NSString*)otherTitles, ...NS_REQUIRES_NIL_TERMINATION;

+ (UIAlertView*)alertViewWithTitle:(NSString*)title message:(NSString*)message cancelButtonTitle:(NSString*)cbtitle okButtonTitle:(NSString*)oktitle inputText:(NSString*)inputMessage placeHolder:(NSString*)placeholder autoFocus:(BOOL)autofocus secureText:(BOOL)secure actionBlock:(void(^)(UIAlertView*, NSInteger,NSString*))block;

- (void)setKeyBoardType:(UIKeyboardType)kt;
@end
