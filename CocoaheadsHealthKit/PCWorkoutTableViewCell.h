//
//  PCWorkoutTableViewCell.h
//  CocoaheadsHealthKit
//
//  Created by Phillipe Casorla Sagot on 29/11/14.
//  Copyright (c) 2014 PCS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCWorkoutTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *caloriesLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

+ (NSString*) identifier;
@end
