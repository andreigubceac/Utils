//
//  AGWeatherManager.h
//
//  Created by Andrei Gubceac on 10/10/13.
//  Copyright (c) 2013. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BlocksAdditions.h"

@interface AGWeatherManager : NSObject

- (void)weatherDataForNextDays:(NSUInteger)nextNrDays forCoordinates:(CLLocationCoordinate2D)coordinates
                 completeBlock:(ResultBlock)cblock errorBlock:(ErrorBlock)errorBlock;
- (void)locationDataForCoordinates:(CLLocationCoordinate2D)coordinates
                     completeBlock:(ResultBlock)cblock errorBlock:(ErrorBlock)errorBlock;

@end
