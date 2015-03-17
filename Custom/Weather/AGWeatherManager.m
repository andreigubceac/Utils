//
//  MFWeatherManager.m
//
//  Created by Andrei Gubceac on 10/10/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "AGWeatherManager.h"
#import "NSArray+Additions.h"

const NSString *_key = @"a79a9a44e0671cd5fffe63aa070c7";
NSString *kWeatherDateFormat = @"YYYY-MM-dd";

@interface AGWeatherManager ()
{
    NSMutableDictionary *_connectionInProgress, *_connectionsInPendding;
    NSMutableArray *_weatherObjects;
    NSCache *_weatherIcons;
    id _location;
    CLLocationCoordinate2D _lastCoordinates;
}
@end

@implementation AGWeatherManager

- (id)init
{
    self = [super init];
    if (self)
    {
        _weatherObjects = [NSMutableArray array];
        _location       = [NSMutableDictionary dictionary];
        _weatherIcons   = [[NSCache alloc] init];
        _connectionInProgress   = [[NSMutableDictionary alloc] init];
        _connectionsInPendding  = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_weatherIcons removeAllObjects];
    _weatherIcons = nil;
    [_weatherObjects removeAllObjects];
    _weatherObjects = nil;
}

- (void)cancelAllInProgressConnections
{
    [[_connectionInProgress allValues] makeObjectsPerformSelector:@selector(cancel) withObject:nil];
    [_connectionInProgress removeAllObjects];
    [[_connectionsInPendding allValues] makeObjectsPerformSelector:@selector(cancel) withObject:nil];
    [_connectionsInPendding removeAllObjects];
}

- (void)resetData
{
    [_weatherObjects removeAllObjects];
    [_location removeAllObjects];
    [self cancelAllInProgressConnections];
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

static int maxConnectionInprogress = 10;

- (BOOL)isInProgressConnectionForPath:(NSString*)absoluteString
{
    NSString *_connectionKey = [absoluteString copy];
    return ([_connectionInProgress objectForKey:_connectionKey] || [_connectionsInPendding objectForKey:_connectionKey]);
}

- (void)weatherDataForNextDays:(NSUInteger)nextNrDays forCoordinates:(CLLocationCoordinate2D)coordinates
                 completeBlock:(ResultBlock)cblock errorBlock:(CommunicationErrorBlock)errorBlock
{
    if (_lastCoordinates.latitude != coordinates.latitude && _lastCoordinates.longitude != coordinates.longitude)
        [self resetData];
    
    if ([_weatherObjects count])
    {
        if (cblock)
            cblock(_weatherObjects);
        return;
    }
    if (CLLocationCoordinate2DIsValid(coordinates) == NO)
    {
        if (errorBlock)
            errorBlock(400, [NSError errorWithDomain:@"CoreLocation" code:400 userInfo:@{NSLocalizedDescriptionKey :@"Invalid geo coordinates"}]);
        return;
    }
    
    NSString *_connectionKey = [NSString stringWithFormat:@"q=%f,%f",coordinates.latitude,coordinates.longitude];
    if ([self isInProgressConnectionForPath:_connectionKey])
    {
        return ;
    }

    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.worldweatheronline.com/free/v2/weather.ashx?%@&format=json&num_of_days=%lu&key=%@",_connectionKey,(unsigned long)nextNrDays,_key]]];
    __block NSURLConnectionWithBlocks *connection = nil;
    connection = [NSURLConnectionWithBlocks connectionWithRequest:req startImmediately:NO
                                                     successBlock:^(NSHTTPURLResponse *res, NSData *resBody){
                                                         NSError *jsonError = nil;
                                                         NSDictionary *_json = [NSJSONSerialization JSONObjectWithData:resBody
                                                                                                               options:NSJSONReadingAllowFragments
                                                                                                                 error:&jsonError];
                                                         if (jsonError == nil)
                                                         {
                                                             [_weatherObjects removeAllObjects];
                                                             [_weatherObjects addObjectsFromArray:[_json valueForKey:@"data"][@"weather"]];
                                                             id _fObject = [NSMutableDictionary dictionaryWithDictionary:[_json[@"data"][@"current_condition"] lastObject]];
                                                             [_fObject setValue:_weatherObjects.firstObject[@"date"] forKey:@"date"];
                                                             [_weatherObjects removeFirstObject];
                                                             [_weatherObjects insertObject:_fObject atIndex:0];
                                                             cblock(_weatherObjects);
                                                         }
                                                     }
                                                   httpErrorBlock:nil
                                                       errorBlock:^(NSString *errStr, NSError *err) { errorBlock([err code],err); }
                                                    completeBlock:^(NSURLConnection*_connection){
                                                        [_connectionInProgress removeObjectForKey:_connectionKey];
                                                        if ([_connectionInProgress allValues].count == 0)
                                                        {
                                                            for (unsigned i=0;i<maxConnectionInprogress&&i<[[_connectionsInPendding allValues] count];i++)
                                                            {
                                                                NSURLConnectionWithBlocks *conn = [[_connectionsInPendding allValues] objectAtIndex:i];
                                                                [_connectionInProgress setValue:conn forKey:conn.identifier];
                                                                [_connectionsInPendding removeObjectForKey:conn.identifier];
                                                                [conn start];
                                                            }
                                                        }
                                                        _lastCoordinates = coordinates;
                                                    }];
    if (connection)
    {
        connection.identifier = _connectionKey;
        if ([_connectionInProgress allValues].count < maxConnectionInprogress)
        {
            [_connectionInProgress setValue:connection forKey:_connectionKey];
            [connection start];
        }
        else
            [_connectionsInPendding setValue:connection forKey:_connectionKey];
    }
}

- (void)locationDataForCoordinates:(CLLocationCoordinate2D)coordinates
                     completeBlock:(ResultBlock)cblock errorBlock:(CommunicationErrorBlock)errorBlock
{
    if ([_location count])
    {
        if (cblock)
            cblock(_location);
        return;
    }
    if (CLLocationCoordinate2DIsValid(coordinates) == NO)
    {
        if (errorBlock)
            errorBlock(400, [NSError errorWithDomain:@"CoreLocation" code:400 userInfo:@{NSLocalizedDescriptionKey :@"Invalide geo coordinates"}]);
        return;
    }
    
    NSString *_connectionKey = [[NSValue valueWithMKCoordinate:coordinates] description];

    if ([self isInProgressConnectionForPath:_connectionKey])
    {
        return ;
    }
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.worldweatheronline.com/free/v2/search.ashx?q=%f,%f&format=json&num_of_results=1&key=%@",coordinates.latitude,coordinates.longitude, _key]]];
    __block NSURLConnectionWithBlocks *connection = nil;
    connection = [NSURLConnectionWithBlocks connectionWithRequest:req startImmediately:NO
                                                     successBlock:^(NSHTTPURLResponse *res, NSData *_jsonData){
                                                         NSError *_err = nil;
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
                                                                 cblock(_location);
                                                             }
                                                             else if (cblock)
                                                                cblock(nil);
                                                         }
                                                         else if (errorBlock)
                                                             errorBlock(_err.code, _err);
                                                     }
                                                   httpErrorBlock:nil
                                                       errorBlock:^(NSString *errStr, NSError *err) { errorBlock([err code],err); }
                                                    completeBlock:^(NSURLConnection*_connection){
                                                        [_connectionInProgress removeObjectForKey:_connectionKey];
                                                        if ([_connectionInProgress allValues].count == 0)
                                                        {
                                                            for (unsigned i=0;i<maxConnectionInprogress&&i<[[_connectionsInPendding allValues] count];i++)
                                                            {
                                                                NSURLConnectionWithBlocks *conn = [[_connectionsInPendding allValues] objectAtIndex:i];
                                                                [_connectionInProgress setValue:conn forKey:conn.identifier];
                                                                [_connectionsInPendding removeObjectForKey:conn.identifier];
                                                                [conn start];
                                                            }
                                                        }
                                                    }];
    if (connection)
    {
        connection.identifier = _connectionKey;
        if ([_connectionInProgress allValues].count < maxConnectionInprogress)
        {
            [_connectionInProgress setValue:connection forKey:_connectionKey];
            [connection start];
        }
        else
            [_connectionsInPendding setValue:connection forKey:_connectionKey];
    }
}
@end
