//
//  UIDevice+Additions.m
//
//  Created by Andrei Gubceac on 1/18/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "UIDevice+Additions.h"


@implementation UIDevice (Additions)

+ (UIDeviceType)deviceType
{
    UIDeviceType thisDevice = 0;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        thisDevice |= UIDeviceTypeIPhone;
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)])
        {
            if ([UIScreen mainScreen].scale > 1.)
            {
                thisDevice |= UIDeviceTypeIPhoneRetina;
                if ([[UIScreen mainScreen] bounds].size.height == 568)
                    thisDevice |= UIDeviceTypeIPhone5;
                else if ([[UIScreen mainScreen] bounds].size.height == 667)
                    thisDevice |= UIDeviceTypeIPhone6;
                else if ([[UIScreen mainScreen] bounds].size.height == 736)
                    thisDevice |= UIDeviceTypeIPhone6;
            }
        }
    }
    else
    {
        thisDevice |= UIDeviceTypeIPad;
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)])
            if ([UIScreen mainScreen].scale > 1.)
                thisDevice |= UIDeviceTypeIPadRetina;
    }
    return thisDevice;
}


@end