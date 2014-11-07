//
//  UIDevice+Additions.h
//
//  Created by Andrei Gubceac on 1/18/13.
//  Copyright (c) 2013. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    UIDeviceTypeIPhone          = 1 << 1,
    UIDeviceTypeIPhoneRetina    = 1 << 2,
    UIDeviceTypeIPhone5         = 1 << 3,
    UIDeviceTypeIPhone6         = 1 << 4,
    UIDeviceTypeIPhone6Plus     = 1 << 5,
    UIDeviceTypeIPad            = 1 << 6,
    UIDeviceTypeIPadRetina      = 1 << 7
    
} UIDeviceType;

@interface UIDevice (Screen)
+ (UIDeviceType)deviceType;
@end
