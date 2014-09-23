//
//  AGLocationManager.m
//
//  Created by Andrei Gubceac on 8/17/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "AGLocationManager.h"

@interface AGLocationManager ()<CLLocationManagerDelegate>
{
    CLLocationManager *_locationManager;
    CLGeocoder *_geocoder;
}
@property (nonatomic, copy) void(^lblock)(CLLocation*,NSError*);
@property (nonatomic, copy) void(^pblock)(CLPlacemark*,NSError*);
@end

@implementation AGLocationManager

- (id)init
{
    self = [super init];
    if (self)
    {
        self.delegate = self;
        self.distanceFilter = kCLLocationAccuracyBest;
        self.desiredAccuracy = kCLLocationAccuracyBest;
        _geocoder = [[CLGeocoder alloc] init];
    }
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
    [self stopUpdatingLocation];
}

- (void)locationWithCompleteBlock:(void(^)(CLLocation*,NSError*))block refresh:(BOOL)yes
{
    if ([CLLocationManager locationServicesEnabled])
    {
        if (self.location && yes == NO)
        {
            if (block)
                block(self.location, nil);
        }
        else
        {
            self.lblock = block;
            [self startUpdatingLocation];
            self.delegate = self;
        }
    }
    else if (block)
        block(nil,[NSError errorWithDomain:NSStringFromClass([CLLocation class]) code:404 userInfo:@{NSLocalizedDescriptionKey: [AGLocationManager userFriendlyauthorizationStatus]}]);
}

+ (NSString*)userFriendlyauthorizationStatus
{
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusAuthorizedAlways: return nil;
        case kCLAuthorizationStatusAuthorizedWhenInUse: return nil;
        case kCLAuthorizationStatusDenied: return @"Location services are disabled in Settings";
        case kCLAuthorizationStatusNotDetermined: return @"User has not yet made a choice with regards to this application";
        case kCLAuthorizationStatusRestricted: return @"This application is not authorized to use location services. Due to active restrictions on location services, the user cannot change this status, and may not have personally denied authorization";
    }
    return nil;
}

- (void)placemarkForLocation:(CLLocation*)location//pass nil to use the default location
               completeBlock:(void(^)(CLPlacemark*,NSError*))block;
{
    self.pblock = block;
    if (self.location == nil && location == nil)
        [self locationWithCompleteBlock:^(CLLocation *l, NSError *e) {
            if (e)
            {
                if (block)
                    block(nil,e);
            }
            else
                [self placemarkForLocation:l completeBlock:block];
        } refresh:YES];
    else if (self.pblock)
    {
        [_geocoder reverseGeocodeLocation:(location?location:self.location) completionHandler:^(NSArray *placemarks, NSError *error) {
                self.pblock([placemarks firstObject],error);
        }];
    }
}

@end

@implementation AGLocationManager (CLLocationManager)

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [self stopUpdatingLocation];
    self.delegate = nil;
    if (self.lblock)
        self.lblock(newLocation,nil);
    if (self.pblock)
    {
        [_geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            self.pblock([placemarks firstObject],error);
        }];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self stopUpdatingLocation];
    if (self.lblock)
        self.lblock(nil,error);
}

@end