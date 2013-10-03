//
//  UIButton+Additions.h
//
//  Created by Andrei Gubceac on 12/11/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Additions)
+ (UIButton*)buttonWithType:(UIButtonType)buttonType actionBlock:(void(^)(UIButton* b, BOOL toggle))block;
+ (UIButton*)buttonWithNormalImage:(NSString*)normalImage toggleImage:(NSString*)toggleImage actionBlock:(void(^)(UIButton* b, BOOL toggle))block;
@end

