//
//  AGWeatherManager.h
//
//  Created by Andrei Gubceac on 10/10/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "NSURLConnection+Blocks.h"
#import "BlocksAdditions.h"

extern NSString *kWeatherDateFormat;

@interface AGWeatherManager : NSObject
- (void)resetData;
- (NSString*)weatherConditionForCode:(NSNumber*)code;

- (void)weatherDataForNextDays:(NSUInteger)nextNrDays forCoordinates:(CLLocationCoordinate2D)coordinates
                 completeBlock:(ResultBlock)cblock errorBlock:(CommunicationErrorBlock)errorBlock;
- (void)locationDataForCoordinates:(CLLocationCoordinate2D)coordinates
                     completeBlock:(ResultBlock)cblock errorBlock:(CommunicationErrorBlock)errorBlock;

@end
