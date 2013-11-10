//
//  AGModalView.h
//
//  Created by Andrei Gubceac on 11/10/13.
//  Copyright (c) 2013. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AGModalView : UIView
@property (nonatomic, copy) void(^completeBlock)(id info);

- (void)showAnimated:(BOOL)animated;
- (void)hideAnimated:(BOOL)animated;
@end
