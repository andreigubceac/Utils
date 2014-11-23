//
//  NSObject+Additions.m
//
//  Created by Andrei Gubceac on 1/18/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "NSObject+Additions.h"

@implementation NSObject (Additions)
+ (id)loadFromNibWithOwner:(id)owner
{
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:owner options:nil] objectAtIndex:0];;
}

+ (id)loadFromNib
{
    return [[self class] loadFromNibWithOwner:nil];
}

+ (NSString*)appInfoVersion
{
    static NSString* _appVersion;
    if (nil == _appVersion)
        _appVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    return _appVersion;
}

+ (NSString*)appBundleVersion
{
    static NSString* _appVersion;
    if (nil == _appVersion)
        _appVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
    return _appVersion;
}

+ (NSString*)bundleIdentifier
{
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"];
}
@end

@implementation NSObject (json)

- (void)updateFromJson:(id)o{}

- (id)jsonObject{return [NSNull null];}

@end

