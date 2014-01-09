//
//  AGLocationManager.h
//
//  Created by Andrei Gubceac on 8/17/13.
//  Copyright (c) 2013. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface AGLocationManager : CLLocationManager
+ (NSString*)userFriendlyauthorizationStatus;
- (void)locationWithCompleteBlock:(void(^)(CLLocation*,NSError*))block refresh:(BOOL)yes;
- (void)placemarkForLocation:(CLLocation*)location//pass nil to use the default location
               completeBlock:(void(^)(CLPlacemark*,NSError*))block;
@end
