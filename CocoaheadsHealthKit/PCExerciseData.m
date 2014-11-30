//
//  PCStepsData.m
//  CocoaheadsHealthKit
//
//  Created by Phillipe Casorla Sagot on 26/11/14.
//  Copyright (c) 2014 PCS. All rights reserved.
//

#import "PCExerciseData.h"

@implementation PCExerciseData

+ (instancetype) buildWithSteps:(NSInteger) todaySteps time:(NSTimeInterval)todayTime andDistance:(double)todayDistance{
    return [[self alloc] initBuildWithSteps:todaySteps time:todayTime distance:todayDistance calories:0 workoutName:@"Steps"];
}
+ (instancetype) buildWithWorkoutName:(NSString*) name time:(NSTimeInterval)workoutTime distance:(double)workoutDistance withCalories:(double)workoutCalories{
    return [[self alloc] initBuildWithSteps:0 time:workoutTime distance:workoutDistance calories:workoutCalories workoutName:name];
}
- (instancetype) initBuildWithSteps:(NSInteger) todaySteps
                              time:(NSTimeInterval)todayTime
                          distance:(double)todayDistance
                          calories:(double)workoutCalories
                       workoutName:(NSString*)workoutName{
    self = [super init];
    if (self) {
        _steps = todaySteps;
        _time = todayTime;
        _distance = todayDistance;
        _calories = workoutCalories;
        _name = workoutName;
    }
    return self;
}

- (double) stepsCaloriesWithWeight:(double)weight{
#define kMotionMinToHour 0.0166667
    double speed = _distance / (_time*kMotionMinToHour);
    double calories = (0.0215 * pow(speed, 3) - 0.1765 * pow(speed, 2) + 0.8710 * speed + 1.4577) * weight * (_time*kMotionMinToHour);
    return floorf(calories);
}
@end
