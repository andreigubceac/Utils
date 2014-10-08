//
//  AGAnalytics.h
//  MobiFind
//
//  Created by Andrei Gubceac on 10/2/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGAnalytics : NSObject
- (void)logEvent:(NSString *)eventName withParameters:(NSDictionary *)parameters timed:(BOOL)timed;
- (void)endTimedEvent:(NSString *)eventName withParameters:(NSDictionary *)parameters;	// non-nil parameters will update the parameters
@end
