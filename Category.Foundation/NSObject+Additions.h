//
//  NSObject+Additions.h
//
//  Created by Andrei Gubceac on 1/18/13.
//  Copyright (c) 2013. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSObject (Additions)
+ (id)loadFromNibWithOwner:(id)owner;
+ (id)loadFromNib;
+ (NSString*)bundleIdentifier;
+ (NSString*)appInfoVersion;
+ (NSString*)appBundleVersion;
@end

inline static id nilToNull(id obj)  {return (obj == nil) ? [NSNull null] : obj;}

inline static id nullToNil(id obj)  {return ([obj isKindOfClass:[NSNull class]] ? nil : obj);}

@interface NSObject (json)
- (void)updateFromJson:(id)o;
- (id)jsonObject;
@end
