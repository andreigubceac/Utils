//
//  UIActionSheet+Blocks.m
//
//  Created by Andrei Gubceac on 1/26/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "UIActionSheet+Blocks.h"

@interface UIActionSheetWithBlocks : UIActionSheet<UIActionSheetDelegate>
@property (nonatomic, copy) void(^cancelBlock)(void);
@property (nonatomic, copy) void(^destructiveBlock)(void);
@property (nonatomic, copy) void(^otherBlock)(NSUInteger buttonIndex, NSString *buttonTitle);
@end

@implementation UIActionSheetWithBlocks;
@end

@implementation UIActionSheet (Blocks)

+ (UIActionSheet*)actionSheetWithTitle:(NSString*)title
                               cancelButtonTitle:(NSString*)cancelTitle cancelButtonBlock:(void(^)(void))cblock
                          destructiveButtonTitle:(NSString*)destructiveTitle destructiveButtonBlock:(void(^)(void))dblock
                                otherButtonBlock:(void(^)(NSUInteger, NSString*))oblock
                               otherButtonTitles:(NSString*)otherTitles, ...
{
    
    UIActionSheetWithBlocks *_actionSheet = [UIActionSheetWithBlocks alloc];
    _actionSheet = [_actionSheet initWithTitle:title delegate:_actionSheet
                             cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
    
    va_list args;
    va_start(args, otherTitles);
    for (NSString *arg = otherTitles; arg != nil; arg = va_arg(args, NSString*))
        [_actionSheet addButtonWithTitle:arg];
    
    va_end(args);
    _actionSheet.otherBlock = oblock;
    if ([destructiveTitle length])
    {
        [_actionSheet addButtonWithTitle:destructiveTitle];
        _actionSheet.destructiveBlock = dblock;
        _actionSheet.destructiveButtonIndex = [_actionSheet numberOfButtons]-1;
    }
    _actionSheet.cancelBlock = cblock;
    [_actionSheet addButtonWithTitle:cancelTitle];
    _actionSheet.cancelButtonIndex = [_actionSheet numberOfButtons]-1;
    return _actionSheet;
}

+ (UIActionSheet*)actionSheetWithTitle:(NSString*)title
                     cancelButtonTitle:(NSString*)cancelTitle cancelButtonBlock:(void(^)(void))cblock
                destructiveButtonTitle:(NSString*)destructiveTitle destructiveButtonBlock:(void(^)(void))dblock
                      otherButtonBlock:(void(^)(NSUInteger, NSString*))oblock
                otherButtonTitlesArray:(NSArray*)otherTitlesArray
{
    
    UIActionSheetWithBlocks *_actionSheet = [UIActionSheetWithBlocks alloc];
    _actionSheet = [_actionSheet initWithTitle:title delegate:_actionSheet
                             cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
    for (id _title in otherTitlesArray)
        if ([_title isKindOfClass:[NSString class]])
            [_actionSheet addButtonWithTitle:_title];

    if ([destructiveTitle length])
    {
        [_actionSheet addButtonWithTitle:destructiveTitle];
        _actionSheet.destructiveButtonIndex = _actionSheet.numberOfButtons-1;
    }
    
    if ([cancelTitle length])
    {
        [_actionSheet addButtonWithTitle:cancelTitle];
        _actionSheet.cancelButtonIndex = _actionSheet.numberOfButtons-1;
    }
    _actionSheet.cancelBlock = cblock;
    _actionSheet.destructiveBlock = dblock;
    _actionSheet.otherBlock = oblock;
    return _actionSheet;
}

@end

@implementation UIActionSheetWithBlocks (UIActionSheetDelegate)

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.cancelButtonIndex == buttonIndex)
    {
        if (self.cancelBlock)
            self.cancelBlock();
    }
    else if (actionSheet.destructiveButtonIndex == buttonIndex)
    {
        if (self.destructiveBlock)
            self.destructiveBlock();
    }
    else if (self.otherBlock)
        self.otherBlock(buttonIndex,[actionSheet buttonTitleAtIndex:buttonIndex]);
}

@end