//
//  TravelObjectCell.m
//  Travel Plan Example
//
//  Created by Bartosz Dudar on 24.10.2016.
//  Copyright © 2016 Bartosz Dudar. All rights reserved.
//

#import "TravelObjectCell.h"
#import "Travel_Plan_Example-Swift.h"
#import "APIManager.h"
#import "AppDelegate.h"

@interface  TravelObjectCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoHeightConstraint;

@end

@implementation TravelObjectCell

- (void)configureForObject:(TravelObject *)travelObject {
    
    [self.departuteTimeLabel setText:travelObject.departureTimeString];
    [self.arrivalTimeLabel setText:travelObject.arrivalTimeString];
    
    NSString *priceString;
    if (travelObject.price) {
        priceString = [NSString stringWithFormat:@"%@\u20ac", travelObject.price];
    } else {
        priceString = @"N/A";
    }
    self.priceLabel.text = priceString;
    
    if (travelObject.stopsCount.integerValue == 0) {
        self.stopsLabel.text = @"Direct";
    } else if (travelObject.stopsCount.integerValue == 1) {
        self.stopsLabel.text = @"1 stop";
    } else if (travelObject.stopsCount.integerValue == 2) {
        self.stopsLabel.text = [NSString stringWithFormat:@"%lu stops", travelObject.stopsCount.integerValue];
    }
    
    self.departuteTimeLabel.text = [travelObject departureTimeString];
    self.arrivalTimeLabel.text = [travelObject arrivalTimeString];
    self.durationLabel.text = [travelObject travelDurationString];
    
    [self configureImageForObject:travelObject];
}

- (void)configureImageForObject:(TravelObject *)travelObject {
    NSString *typeImageName;
    
    switch (travelObject.type.integerValue) {
        case TravelObjectTypeTrain:
            typeImageName = @"Train Icon";
            break;
        case TravelObjectTypeFlight:
            typeImageName = @"Plane Icon";
            break;
        case TravelObjectTypeBus:
            typeImageName = @"Bus Icon";
            break;
    }
    
    self.typeIconImageView.image = [UIImage imageNamed:typeImageName];
    
    if (travelObject.logoImageData) {
        
        UIImage* image = [[UIImage alloc] initWithData:travelObject.logoImageData];
        
        CGFloat imageAspectRatio = image.size.width / image.size.height;
        
        self.logoWidthConstraint.constant = self.logoHeightConstraint.constant * imageAspectRatio;
        [self.logoImageView setImage:image];
        
    } else {
        
        [self.logoImageView setImage:nil];
        
        if (travelObject.identifier != nil) {
            
            switch (travelObject.type.integerValue) {
                case TravelObjectTypeTrain:
                    [[APIManager sharedInstance] getImageForTrainObjectWithId:travelObject.identifier.integerValue];
                    break;
                case TravelObjectTypeFlight:
                    [[APIManager sharedInstance] getImageForFlightObjectWithId:travelObject.identifier.integerValue];
                    break;
                case TravelObjectTypeBus:
                    [[APIManager sharedInstance] getImageForBusObjectWithId:travelObject.identifier.integerValue];
                    break;
            }
        }
    }
}

@end
