//
//  TravelObjectCell.h
//  Travel Plan Example
//
//  Created by Bartosz Dudar on 24.10.2016.
//  Copyright © 2016 Bartosz Dudar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TravelObject;

@interface TravelObjectCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *departuteTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *arrivalTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *stopsLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet UIImageView *typeIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

- (void)configureForObject:(TravelObject *)travelObject;

@end
