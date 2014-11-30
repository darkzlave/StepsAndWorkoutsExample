//
//  PCWorkoutTableViewCell.m
//  CocoaheadsHealthKit
//
//  Created by Phillipe Casorla Sagot on 29/11/14.
//  Copyright (c) 2014 PCS. All rights reserved.
//

#import "PCWorkoutTableViewCell.h"

@implementation PCWorkoutTableViewCell
+ (NSString*) identifier{
    return NSStringFromClass(self);
}
- (void)awakeFromNib {
    // Initialization code
    self.contentView.backgroundColor = [UIColor colorWithRed:188/255.0f green:81/155.0f blue:1.0f alpha:1.0f];
    self.selectedBackgroundView = nil;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
