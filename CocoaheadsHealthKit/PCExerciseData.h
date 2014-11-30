//
//  PCStepsData.h
//  CocoaheadsHealthKit
//
//  Created by Phillipe Casorla Sagot on 26/11/14.
//  Copyright (c) 2014 PCS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCExerciseData : NSObject
@property (nonatomic,readonly) NSInteger steps;
@property (nonatomic,readonly) NSTimeInterval time;
@property (nonatomic,readonly) double distance;
@property (nonatomic,readonly) double calories;
@property (nonatomic,readonly, strong) NSString* name;

+(instancetype) buildWithSteps:(NSInteger) todaySteps time:(NSTimeInterval)todayTime andDistance:(double)todayDistance;
+(instancetype) buildWithWorkoutName:(NSString*) name time:(NSTimeInterval)workoutTime distance:(double)workoutDistance withCalories:(double)workoutCalories;

-(double) stepsCaloriesWithWeight:(double) weight;
@end
