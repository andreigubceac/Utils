//
//  MFWeatherManager.m
//
//  Created by Andrei Gubceac on 10/10/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "AGWeatherManager.h"

const NSString *_key = @"e3aebbbb4w22caasjxkpcs6v";

@interface AGWeatherManager ()
{
    BOOL _inPogress, _inProgressLocation;
    NSMutableArray *_weatherObjects;
    id _location;
    NSTimer *_resetTimer;
}
@end

@implementation AGWeatherManager

- (id)init
{
    self = [super init];
    if (self)
    {
        _weatherObjects = [NSMutableArray array];
        _location = [NSMutableDictionary dictionary];
        _resetTimer = [NSTimer scheduledTimerWithTimeInterval:3600 target:self selector:@selector(resetData:) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)dealloc
{
    [_weatherObjects removeAllObjects];
    _weatherObjects = nil;
    [_resetTimer invalidate];
    _resetTimer = nil;
}

- (void)resetData:(id)t
{
    [_weatherObjects removeAllObjects];
    [_location removeAllObjects];
    _inProgressLocation = _inPogress = NO;
}

- (NSString*)weatherConditionForCode:(NSNumber*)code
{
    NSUInteger _cod = [code intValue];
    if (_cod == 119 || _cod == 116 || _cod == 143 || _cod == 266 || _cod == 263)
        return @"Cloudy";
    else if (_cod == 389 || _cod == 386 || _cod == 359 || _cod == 356 || _cod == 353 || _cod == 314 || _cod == 308 || _cod == 305 || _cod == 305 || _cod == 302 || _cod == 299 || _cod == 296 || _cod == 293 || _cod == 197 || _cod == 122 || _cod == 176)
        return @"Rainy";
    else if (_cod == 395 || _cod == 392 || _cod == 371 || _cod == 368 || _cod == 338 || _cod == 335 || _cod == 332 || _cod == 329 || _cod == 326 || _cod == 323 || _cod == 227 || _cod == 179)
        return @"Snowy";
    else if (_cod == 113)
        return @"Sunny";
    return nil;
};


- (void)weatherDataForNextDays:(NSUInteger)nextNrDays forCoordinates:(CLLocationCoordinate2D)coordinates
                 completeBlock:(ResultBlock)cblock errorBlock:(ErrorBlock)errorBlock
{
    if (_inPogress)
        return;
    else if ([_weatherObjects count])
        cblock(_weatherObjects);
    
    if (CLLocationCoordinate2DIsValid(coordinates) == NO)
    {
        if (errorBlock)
            errorBlock(@"Invalid coordinates");
        return;
    }
    _inPogress = YES;
    dispatch_queue_t queue = dispatch_queue_create("com.123dressme.weater", 0);
    dispatch_async(queue, ^{
        NSError *_err = nil;
        NSData *_jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.worldweatheronline.com/free/v1/weather.ashx?q=%f,%f&format=json&num_of_days=%d&key=%@",coordinates.latitude,coordinates.longitude,nextNrDays,_key]]
                                                  options:NSDataReadingMapped
                                                    error:&_err];
        if (_err == nil)
        {
            NSDictionary *_json = [NSJSONSerialization JSONObjectWithData:_jsonData
                                                                  options:NSJSONReadingAllowFragments
                                                                    error:&_err];
            if (_err == nil)
            {
                [_weatherObjects removeAllObjects];
                [_weatherObjects addObjectsFromArray:[_json valueForKey:@"data"][@"weather"]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    cblock(_weatherObjects);
                });
            }
            else if (errorBlock)
                dispatch_async(dispatch_get_main_queue(), ^{
                    errorBlock([_err localizedDescription]);
                });
        }
        else if (errorBlock)
            dispatch_async(dispatch_get_main_queue(), ^{
                errorBlock([_err localizedDescription]);
            });
        _inPogress = NO;
    });
}

- (void)locationDataForCoordinates:(CLLocationCoordinate2D)coordinates
                     completeBlock:(ResultBlock)cblock errorBlock:(ErrorBlock)errorBlock
{
    if (_inProgressLocation)
        return;
    else if ([_location count])
        cblock(_location);
    
    if (CLLocationCoordinate2DIsValid(coordinates) == NO)
    {
        if (errorBlock)
            errorBlock(@"Invalid coordinates");
        return;
    }
    _inProgressLocation = YES;
    dispatch_queue_t queue = dispatch_queue_create("com.123dressme.location", 0);
    dispatch_async(queue, ^{
        NSError *_err = nil;
        NSData *_jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.worldweatheronline.com/free/v1/search.ashx?q=%f,%f&format=json&num_of_results=1&key=%@",coordinates.latitude,coordinates.longitude, _key]]
                                                  options:NSDataReadingMapped
                                                    error:&_err];
        if (_err == nil)
        {
            NSDictionary *_json = [NSJSONSerialization JSONObjectWithData:_jsonData
                                                                  options:NSJSONReadingAllowFragments
                                                                    error:&_err];
            if (_err == nil)
            {
                id _locObject = [_json[@"search_api"][@"result"] lastObject];
                if (_locObject)
                {
                    [_location removeAllObjects];
                    [_location setValue:[_locObject[@"areaName"] lastObject][@"value"] forKey:@"areaName"];
                    [_location setValue:[_locObject[@"region"] lastObject][@"value"] forKey:@"region"];
                    [_location setValue:[_locObject[@"country"] lastObject][@"value"] forKey:@"country"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cblock(_location);
                    });
                }
                else
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cblock(nil);
                    });
            }
            else if (errorBlock)
                dispatch_async(dispatch_get_main_queue(), ^{
                    errorBlock([_err localizedDescription]);
                });
        }
        else if (errorBlock)
            dispatch_async(dispatch_get_main_queue(), ^{
                errorBlock([_err localizedDescription]);
            });
        _inProgressLocation = NO;
    });
}
@end
