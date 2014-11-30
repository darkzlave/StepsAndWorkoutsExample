//
//  PCHealthCoordinator.h
//  CocoaheadsHealthKit
//
//  Created by Phillipe Casorla Sagot on 23/11/14.
//  Copyright (c) 2014 PCS. All rights reserved.
//

#import <Foundation/Foundation.h>
@import HealthKit;

@class PCExerciseData;

extern NSString * const PCHealthErrorNotification;
extern NSString * const PCHealthStepsLoaded;
extern NSString * const PCHealthWorkoutsLoaded;

@interface PCHealthCoordinator : NSObject

+ (instancetype) sharedCoordinator;
+ (BOOL) isStepsEnabled;
+ (BOOL) isWorkoutsEnabled;

- (PCExerciseData*) stepsForToday;
- (NSArray*) workoutsForToday;

- (void) readDataFromWorkouts:(BOOL)background;
- (void) startTrackingSteps:(BOOL)background;
@end
