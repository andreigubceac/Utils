//
//  UIAlertView+Blocks.m
//
//  Created by Andrei Gubceac on 4/25/13.
//  Copyright (c) 2013 -. All rights reserved.
//

#import "UIAlertView+Blocks.h"

@interface UIAlertViewWithBlocks : UIAlertView<UIAlertViewDelegate>
@property (nonatomic, copy) void(^block)(UIAlertView*, NSInteger);
@property (nonatomic, copy) void(^inputblock)(UIAlertView*, NSInteger, NSString*);
@property (nonatomic) BOOL autoFocus;
@end

@implementation UIAlertViewWithBlocks

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.block || self.inputblock)
    {
        if (self.autoFocus)
        {
            self.inputblock(self,buttonIndex,[[alertView textFieldAtIndex:0] text]);
        }
        else
            self.block(self,buttonIndex);
    }
}

- (void)show
{
    [super show];
    if (self.autoFocus)
        [[self textFieldAtIndex:0] performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:.3];
}

@end


@implementation UIAlertView (Blocks)
+ (UIAlertView*)alertViewWithTitle:(NSString*)title message:(NSString*)message cancelButtonTitle:(NSString*)cancelTitle
                       actionBlock:(void(^)(UIAlertView*, NSInteger))block otherButtonTitles:(NSString*)otherTitles, ...
{
    UIAlertViewWithBlocks *_al = [UIAlertViewWithBlocks alloc];
    _al = [_al initWithTitle:title message:message delegate:_al cancelButtonTitle:cancelTitle otherButtonTitles:nil];
    _al.block = block;
    
    va_list args;
    va_start(args, otherTitles);
    for (NSString *arg = otherTitles; arg != nil; arg = va_arg(args, NSString*))
        [_al addButtonWithTitle:arg];
    va_end(args);
    return _al;
}

+ (UIAlertView*)alertViewWithTitle:(NSString*)title message:(NSString*)message cancelButtonTitle:(NSString*)cbtitle okButtonTitle:(NSString*)oktitle inputText:(NSString*)inputMessage placeHolder:(NSString*)placeholder autoFocus:(BOOL)autofocus secureText:(BOOL)secure actionBlock:(void(^)(UIAlertView*, NSInteger, NSString *))block
{
    UIAlertViewWithBlocks *alertView = [UIAlertViewWithBlocks alloc];
    alertView = [alertView initWithTitle:title message:message delegate:alertView cancelButtonTitle:cbtitle otherButtonTitles:oktitle, nil];
    alertView.alertViewStyle = secure?UIAlertViewStyleSecureTextInput:UIAlertViewStylePlainTextInput;
    [[alertView textFieldAtIndex:0] setText:inputMessage];
    [[alertView textFieldAtIndex:0] setPlaceholder:placeholder];
    alertView.autoFocus = autofocus;
    alertView.inputblock = block;
    return alertView;
}

- (void)setKeyBoardType:(UIKeyboardType)kt
{
    [[self textFieldAtIndex:0] setKeyboardType:kt];
}
@end
