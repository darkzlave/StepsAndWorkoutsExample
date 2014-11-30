//
//  PCHealthCoordinator.m
//  CocoaheadsHealthKit
//
//  Created by Phillipe Casorla Sagot on 23/11/14.
//  Copyright (c) 2014 PCS. All rights reserved.
//

#import "PCHealthCoordinator.h"
#import "PCExerciseData.h"
#import "HKWorkout+name.h"

#define appleSourcePhone @"com.apple.health"
#define kMotionEnabled @"motion_enabled"
#define kWorkoutsEnabled @"workouts_enabled"

#define hkWorkoutsType [HKObjectType workoutType]
#define hkDistanceType [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning]
#define hkStepsType [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]

#define defaultReadPermissions @[hkDistanceType,hkStepsType]

NSString * const  PCHealthErrorNotification = @"HEALTHKIT_ERROR_NOTIFICATION";
NSString * const PCHealthStepsLoaded = @"MOTION_LOADED";
NSString * const PCHealthWorkoutsLoaded = @"WORKOUT_LOADED";

@interface PCHealthCoordinator ()

@property(nonatomic,strong) HKHealthStore *healthStore;

@property (atomic) BOOL processingSteps;
@property (atomic) BOOL processingWorkouts;

@property (nonatomic, strong) NSArray *workouts;
@property (nonatomic, strong) PCExerciseData *stepsDataForToday;

- (BOOL) isHealthCoordinatorAvailable;
@end

@implementation PCHealthCoordinator

+ (instancetype) sharedCoordinator
{
    static dispatch_once_t onceToken;
    static PCHealthCoordinator *coordinator;
    dispatch_once(&onceToken, ^{
        coordinator = [[PCHealthCoordinator alloc] init];
    });
    return coordinator;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        if ([HKHealthStore isHealthDataAvailable]) {
            self.healthStore = [[HKHealthStore alloc] init];
        }
    }
    return self;
}

+ (BOOL) isStepsEnabled{
    BOOL motionActive = [[NSUserDefaults standardUserDefaults] boolForKey:kMotionEnabled];
    return motionActive;
}
+ (BOOL) isWorkoutsEnabled{
    BOOL workoutsActive = [[NSUserDefaults standardUserDefaults] boolForKey:kWorkoutsEnabled];
    return workoutsActive;
}

- (BOOL) isHealthCoordinatorAvailable
{
    return self.healthStore != nil;
}

#pragma mark - Retrieve Data
- (PCExerciseData*) stepsForToday
{
    return self.stepsDataForToday;
}
- (NSArray*) workoutsForToday{
    return self.workouts;
}

#pragma mark - Step/Distance Reading

- (void) stopTrackingSteps
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMotionEnabled];
}

- (void) startTrackingSteps:(BOOL)background
{
    if ([self isHealthCoordinatorAvailable]) {
        //check that if we are comming from the background we have the permissions to read the data
        BOOL motionActive = [PCHealthCoordinator isStepsEnabled];
        if (!motionActive && background) {
            return;
        }
        [self.healthStore requestAuthorizationToShareTypes:nil readTypes:[NSSet setWithArray:defaultReadPermissions] completion:^(BOOL success, NSError *error) {
            if (success) {
                //mark motion as enabled
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kMotionEnabled];
                //collect data inmediatly
                [self queryStepsDistanceData];
                //look for any changes in this range of workout data so we are always in sync
                [self configureBackgroundDeliveryForStepsDistance];
                [self configureObserverQueryForStepsDistance];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:PCHealthErrorNotification object:nil];
            }
        }];
    }
}

- (void) queryStepsDistanceData
{
    //check we are not calling the query several times
    if (!self.processingSteps) {
        self.processingSteps = YES;
        NSPredicate *todayPredicate = [self predicateForToday];
        //data types
        [self queryStepsForPredicate:todayPredicate andCurrentDate:[NSDate date]];
    }
}

- (void) queryStepsForPredicate:(NSPredicate*)pred andCurrentDate:(NSDate*)currentDate
{
    
    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    //query first the steps and then the distance
    HKSampleQuery *stepsQuery = [[HKSampleQuery alloc] initWithSampleType:hkStepsType predicate:pred limit:HKObjectQueryNoLimit sortDescriptors:@[timeSortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if (results.count > 0) {
            double totalSteps = 0;
            for (HKQuantitySample *stepsSample in results) {
                if ([stepsSample.source.bundleIdentifier hasPrefix:appleSourcePhone]) {
                    double steps = [stepsSample.quantity doubleValueForUnit:[HKUnit countUnit]];
                    totalSteps += steps;
                }
            }
            HKSampleQuery *distanceQuery = [[HKSampleQuery alloc] initWithSampleType:hkDistanceType predicate:pred limit:HKObjectQueryNoLimit sortDescriptors:@[timeSortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
                double totalDistance = 0;
                NSTimeInterval totalTime = 0;
                if (results.count > 0) {
                    for (HKQuantitySample *distanceSample in results) {
                        if ([distanceSample.source.bundleIdentifier hasPrefix:appleSourcePhone]) {
                            double kmDistance = [distanceSample.quantity doubleValueForUnit:[HKUnit meterUnitWithMetricPrefix:HKMetricPrefixKilo]];
                            totalDistance += kmDistance;
                            totalTime += [distanceSample.endDate timeIntervalSinceDate:distanceSample.startDate];
                        }
                    }
                    totalTime /= 60.0f;
                    self.stepsDataForToday = [PCExerciseData buildWithSteps:totalSteps time:totalTime andDistance:totalDistance];
                    [[NSNotificationCenter defaultCenter] postNotificationName:PCHealthStepsLoaded object:[self stepsDataForToday]];
                }
                self.processingSteps = NO;
            }];
            [self.healthStore executeQuery:distanceQuery];
        } else {
            self.processingSteps = NO;
        }
    }];
    
    [self.healthStore executeQuery:stepsQuery];
}

- (void) configureBackgroundDeliveryForStepsDistance
{
    HKSampleType *lifesumSteps = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    HKObserverQuery *stepsQuery = [[HKObserverQuery alloc] initWithSampleType:lifesumSteps predicate:[self predicateForToday] updateHandler:^(HKObserverQuery *query, HKObserverQueryCompletionHandler completionHandler, NSError *error) {
        if (!error) {
            [self queryStepsDistanceData];
            completionHandler();
        }
    }];
    [self.healthStore executeQuery:stepsQuery];
}

- (void) configureObserverQueryForStepsDistance
{
    HKSampleType *lifesumSteps = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    [self.healthStore enableBackgroundDeliveryForType:lifesumSteps frequency:HKUpdateFrequencyImmediate withCompletion:^(BOOL success, NSError *error){
        if (success) {
            [self queryStepsDistanceData];
        }
    }];
}


#pragma mark - Collecting Workouts
//main entry point
- (void) readDataFromWorkouts:(BOOL)background
{
    if ([self isHealthCoordinatorAvailable]) {
        //check that if we are comming from the background we have the permissions to read the data
        BOOL workoutsActive = [PCHealthCoordinator isWorkoutsEnabled];
        if (!workoutsActive && background) {
            return;
        }
        [self.healthStore requestAuthorizationToShareTypes:nil readTypes:[NSSet setWithObjects:hkWorkoutsType, nil] completion:^(BOOL success, NSError *error) {
            if (success) {
                //mark workouts as enabled
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kWorkoutsEnabled];
                //collect data inmediatly
                [self queryWorkoutData];
                //look for any changes in this range of workout data so we are always in sync
                [self configureBackgroundDeliveryForWorkouts];
                [self configureObserverQueryForWorkouts];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:PCHealthErrorNotification object:nil];
            }
        }];
    }
}

- (void)configureObserverQueryForWorkouts
{
    HKObserverQuery *workoutsObserver = [[HKObserverQuery alloc] initWithSampleType:[HKSampleType workoutType] predicate:[self predicateForToday] updateHandler:^(HKObserverQuery *query, HKObserverQueryCompletionHandler completionHandler, NSError *error) {
        if (!error) {
            [self queryWorkoutData];
            completionHandler();
        }
    }];
    [self.healthStore executeQuery:workoutsObserver];
}

- (void)configureBackgroundDeliveryForWorkouts
{
    [self.healthStore enableBackgroundDeliveryForType:[HKSampleType workoutType] frequency:HKUpdateFrequencyImmediate withCompletion:^(BOOL success, NSError *error){
        if (success) {
            [self queryWorkoutData];
        }
    }];
}

- (void) queryWorkoutData
{
    //check we are not calling the query several times
    if (!self.processingWorkouts) {
        self.processingWorkouts = YES;
        
        NSPredicate *todayWorkouts = [self predicateForToday];
        NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
        //if you get more than 10 exercises workouts in just 24h would be weird
        HKSampleQuery *exerciseQuery = [[HKSampleQuery alloc] initWithSampleType:hkWorkoutsType predicate:todayWorkouts limit:HKObjectQueryNoLimit sortDescriptors:@[timeSortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
            if (results.count > 0) {
                NSMutableArray *workouts = [@[] mutableCopy];
                
                for (HKWorkout *workout  in results) {
                    NSString *exeName = [NSString stringWithFormat:@"%@ (%@)",[workout nameFromWorkoutActivityType],workout.source.name];
                    
                    double calories = [workout.totalEnergyBurned doubleValueForUnit:[HKUnit kilocalorieUnit]];
                    double distance = [workout.totalDistance doubleValueForUnit:[HKUnit meterUnitWithMetricPrefix:HKMetricPrefixKilo]];
                    double time = (workout.duration/60.0f);
                    [workouts addObject:[PCExerciseData buildWithWorkoutName:exeName time:time distance:distance withCalories:calories]];
                }
                
                self.workouts = workouts;
                [[NSNotificationCenter defaultCenter] postNotificationName:PCHealthWorkoutsLoaded object:workouts];
            }
            //finished querying workouts
            self.processingWorkouts = NO;
        }];
        [self.healthStore executeQuery:exerciseQuery];
    }
}

#pragma mark - Convenience

- (NSPredicate*) predicateForToday
{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:[calendar dateFromComponents:components] options:0];
    
    NSDate *startDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:endDate options:0];
    
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
    return predicate;
}
@end