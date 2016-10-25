//
//  APIManager.m
//  Travel Plan Example
//
//  Created by Bartosz Dudar on 24.10.2016.
//  Copyright © 2016 Bartosz Dudar. All rights reserved.
//

#import "APIManager.h"
#import "AppDelegate.h"
#import "Travel_Plan_Example-Swift.h"

NSString *const APITrainDataUpdatedNotificationName = @"APITrainDataUpdatedNotificationName";
NSString *const APIFlightDataUpdatedNotificationName = @"APIFlightDataUpdatedNotificationName";
NSString *const APIBusDataUpdatedNotificationName = @"APIBusDataUpdatedNotificationName";
NSString *const APILogoImageUpdatedNotificationName = @"APILogoImageUpdatedNotificationName";

NSString *const TrainEndPointURLString = @"https://api.myjson.com/bins/3zmcy";
NSString *const FlightEndPointURLString = @"https://api.myjson.com/bins/w60i";
NSString *const BusEndPointURLString = @"https://api.myjson.com/bins/37yzm";

NSTimeInterval const DataUpdateInterval = 60 * 60;

@interface APIManager ()

@property (nonatomic, assign) BOOL isUpdatingTrainObjects;
@property (nonatomic, assign) BOOL isUpdatingFlightObjects;
@property (nonatomic, assign) BOOL isUpdatingBusObjects;

@property (nonatomic, strong) NSDate *trainUpdatedDate;
@property (nonatomic, strong) NSDate *flightUpdatedDate;
@property (nonatomic, strong) NSDate *busUpdatedDate;

@end

@implementation APIManager

+ (instancetype)sharedInstance {
    
    static APIManager *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[APIManager alloc] init];
        
        sharedInstance.trainUpdatedDate = [[[NSDate alloc] init] dateByAddingTimeInterval:-DataUpdateInterval * 2];
        sharedInstance.flightUpdatedDate = [[[NSDate alloc] init] dateByAddingTimeInterval:-DataUpdateInterval * 2];
        sharedInstance.busUpdatedDate = [[[NSDate alloc] init] dateByAddingTimeInterval:-DataUpdateInterval * 2];
    });
    return sharedInstance;
}

#pragma mark - Get Objects Methods

- (void)getTrainObjects {
    
    NSDate *now = [[NSDate alloc] init];
    if ([[now dateByAddingTimeInterval:-DataUpdateInterval] compare:self.trainUpdatedDate] == NSOrderedAscending) {
        return;
    }
    
    [self getTravelObjectsOfType:TravelObjectTypeTrain];
}

- (void)getFlightObjects {
    
    NSDate *now = [[NSDate alloc] init];
    if ([[now dateByAddingTimeInterval:-DataUpdateInterval] compare:self.flightUpdatedDate] == NSOrderedAscending) {
        return;
    }
    
    [self getTravelObjectsOfType:TravelObjectTypeFlight];
}

- (void)getBusObjects {
    
    NSDate *now = [[NSDate alloc] init];
    if ([[now dateByAddingTimeInterval:-DataUpdateInterval] compare:self.busUpdatedDate] == NSOrderedAscending) {
        return;
    }
    
    [self getTravelObjectsOfType:TravelObjectTypeBus];
}

- (void)getTravelObjectsOfType:(TravelObjectType)type {
    
    NSString *urlString;
    NSString *updateNotificationName;
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    switch (type) {
        case TravelObjectTypeTrain:
            urlString = TrainEndPointURLString;
            updateNotificationName = APITrainDataUpdatedNotificationName;
            self.isUpdatingTrainObjects = YES;
            break;
        case TravelObjectTypeFlight:
            urlString = FlightEndPointURLString;
            updateNotificationName = APIFlightDataUpdatedNotificationName;
            self.isUpdatingFlightObjects = YES;
            break;
        case TravelObjectTypeBus:
            urlString = BusEndPointURLString;
            updateNotificationName = APIBusDataUpdatedNotificationName;
            self.isUpdatingBusObjects = YES;
            break;
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    if (url == nil) {
        [self endUpdatingType:type];
        return;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error != nil) {
            [self endUpdatingType:type];
            NSLog(@"REQUEST ERROR: %@", error);
            return;
        }
        
        NSError *jsonError;
        NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
        
        if (jsonError != nil) {
            [self endUpdatingType:type];
            NSLog(@"JSON PARSING ERROR: %@", error);
            return;
        }
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"TravelObject"];
        request.predicate = [NSPredicate predicateWithFormat:@"type = %d", type];
        NSBatchDeleteRequest *deleteRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
        
        for (NSDictionary *objectJson in json) {
            
            TravelObject *newObject = [TravelObject fromJson:objectJson inContext:delegate.managedObjectContext];
            newObject.type = [NSNumber numberWithInt:type];
        }
        
        NSError *deleteError;
        [delegate.managedObjectContext executeRequest:deleteRequest error:&deleteError];
        
        [delegate.managedObjectContext performBlockAndWait:^{

            NSError *saveError;
            [delegate.managedObjectContext save:&saveError];
            
            if (saveError != nil) {
                NSLog(@"LOGO SAVE ERROR: %@", saveError);
            }
        }];
        
        [self endUpdatingType:type];
        [self postNotificationName:updateNotificationName];
    }];
}

- (void)endUpdatingType:(TravelObjectType)type {
    switch (type) {
        case TravelObjectTypeTrain:
            self.isUpdatingTrainObjects = NO;
            self.trainUpdatedDate = [[NSDate alloc] init];
            break;
        case TravelObjectTypeFlight:
            self.isUpdatingFlightObjects = NO;
            self.flightUpdatedDate = [[NSDate alloc] init];
            break;
        case TravelObjectTypeBus:
            self.isUpdatingBusObjects = NO;
            self.busUpdatedDate = [[NSDate alloc] init];
            break;
    }
}

- (void)postNotificationName:(NSString *) name {
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
}

#pragma mark - Get Updating State Methods

- (BOOL)isUpdatingTrains {
    return self.isUpdatingTrainObjects;
}

- (BOOL)isUpdatingFlights {
    return self.isUpdatingFlightObjects;
}

- (BOOL)isUpdatingBuses {
    return self.isUpdatingBusObjects;
}

#pragma mark - Get Logo Images Methods

- (void)getImageForObject:(TravelObject *)travelObject {
    
    if (travelObject == nil) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURL *url = [NSURL URLWithString:travelObject.logoURL];
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        if (data == nil) {
            return;
        }
        
        [travelObject.managedObjectContext performBlockAndWait:^{
            
            travelObject.logoImageData = data;
            
            NSError *saveError;
            [travelObject.managedObjectContext save:&saveError];
            
            if (saveError != nil) {
                NSLog(@"LOGO SAVE ERROR: %@", saveError);
            }
        }];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:APILogoImageUpdatedNotificationName object:travelObject];
    });
}

- (void)getImageForTrainObjectWithId:(NSUInteger)identifier {
    [self getImageForObject:[self getTravelObjectOfType:TravelObjectTypeTrain withId:identifier]];
}

- (void)getImageForBusObjectWithId:(NSUInteger)identifier {
    [self getImageForObject:[self getTravelObjectOfType:TravelObjectTypeBus withId:identifier]];
}

- (void)getImageForFlightObjectWithId:(NSUInteger)identifier {
    [self getImageForObject:[self getTravelObjectOfType:TravelObjectTypeFlight withId:identifier]];
}

- (TravelObject *)getTravelObjectOfType:(TravelObjectType)type withId:(NSUInteger)identifier {
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"TravelObject"];
    request.predicate = [NSPredicate predicateWithFormat:@"type = %d AND identifier = %d", type, identifier];
    
    NSError *fetchError;
    
    NSArray *results = [delegate.managedObjectContext executeFetchRequest:request error:&fetchError];
    
    if (fetchError == nil && results.count >= 1) {
        return [results objectAtIndex:0];
    } else {
        return nil;
    }
}

@end
