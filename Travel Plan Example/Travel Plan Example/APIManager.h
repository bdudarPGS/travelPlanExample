//
//  APIManager.h
//  Travel Plan Example
//
//  Created by Bartosz Dudar on 24.10.2016.
//  Copyright © 2016 Bartosz Dudar. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const APITrainDataUpdatedNotificationName;
extern NSString *const APIFlightDataUpdatedNotificationName;
extern NSString *const APIBusDataUpdatedNotificationName;
extern NSString *const APILogoImageUpdatedNotificationName;

@interface APIManager : NSObject

+ (instancetype)sharedInstance;

- (void)getTrainObjects;
- (void)getFlightObjects;
- (void)getBusObjects;

- (BOOL)isUpdatingTrains;
- (BOOL)isUpdatingFlights;
- (BOOL)isUpdatingBuses;

- (void)getImageForTrainObjectWithId:(NSUInteger)identifier;
- (void)getImageForBusObjectWithId:(NSUInteger)identifier;
- (void)getImageForFlightObjectWithId:(NSUInteger)identifier;

@end
