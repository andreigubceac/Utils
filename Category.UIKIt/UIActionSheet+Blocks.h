//
//  UIActionSheet+Blocks.h
//
//  Created by Andrei Gubceac on 1/26/13.
//  Copyright (c) 2013. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIActionSheet (Blocks)
+ (UIActionSheet*)actionSheetWithTitle:(NSString*)title
                     cancelButtonTitle:(NSString*)cancelTitle cancelButtonBlock:(void(^)(void))cblock
                destructiveButtonTitle:(NSString*)destructiveTitle destructiveButtonBlock:(void(^)(void))dblock
                      otherButtonBlock:(void(^)(NSUInteger, NSString*))oblock
                     otherButtonTitles:(NSString*)otherTitles, ...NS_REQUIRES_NIL_TERMINATION;

+ (UIActionSheet*)actionSheetWithTitle:(NSString*)title
                     cancelButtonTitle:(NSString*)cancelTitle cancelButtonBlock:(void(^)(void))cblock
                destructiveButtonTitle:(NSString*)destructiveTitle destructiveButtonBlock:(void(^)(void))dblock
                      otherButtonBlock:(void(^)(NSUInteger, NSString*))oblock
                otherButtonTitlesArray:(NSArray*)otherTitlesArray;
@end
