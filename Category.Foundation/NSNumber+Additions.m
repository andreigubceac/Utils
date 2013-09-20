//
//  NSNumber+Additions.m
//
//  Created by Andrei Gubceac on 11/24/12.
//  Copyright (c) 2012s. All rights reserved.
//

#import "NSNumber+Additions.h"

@implementation NSNumber (Additions)

static NSNumberFormatter* _kNumberFormatterWithCommas_shared = nil;

- (NSString*)integerFormatWithCommas
{
    static dispatch_once_t _s_createNumberFormatterOnce;
    dispatch_once(&_s_createNumberFormatterOnce, ^{
        _kNumberFormatterWithCommas_shared = [[NSNumberFormatter alloc] init];
        [_kNumberFormatterWithCommas_shared setNumberStyle:NSNumberFormatterCurrencyStyle];
        [_kNumberFormatterWithCommas_shared setGroupingSize:3];
        [_kNumberFormatterWithCommas_shared setGroupingSeparator:@","];
        [_kNumberFormatterWithCommas_shared setUsesGroupingSeparator:YES];
    });
    return [_kNumberFormatterWithCommas_shared stringFromNumber:self];
}

@end
