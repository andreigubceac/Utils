//
//  UITextField+Additions.h
//
//  Created by Andrei Gubceac on 12/24/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (Additions)
- (BOOL)resignFirstResponderAndMoveToNextFieldWithDoneBlock:(void(^)(void))block;
- (void)updateLeftAccessoryImage:(UIImage*)image;
@end
