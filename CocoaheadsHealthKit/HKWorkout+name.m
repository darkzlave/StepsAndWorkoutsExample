//
//  HKWorkout+name.m
//  CocoaheadsHealthKit
//
//  Created by Phillipe Casorla Sagot on 26/11/14.
//  Copyright (c) 2014 PCS. All rights reserved.
//

#import "HKWorkout+name.h"

@implementation HKWorkout (name)
-(NSString*) nameFromWorkoutActivityType{
    switch (self.workoutActivityType) {
        case HKWorkoutActivityTypeAmericanFootball: return @"American Football";
        case HKWorkoutActivityTypeArchery: return @"Archery";// not supported
        case HKWorkoutActivityTypeAustralianFootball: return @"Football";
        case HKWorkoutActivityTypeBadminton: return @"Badminton";
        case HKWorkoutActivityTypeBaseball: return @"Baseball";// not supported
        case HKWorkoutActivityTypeBasketball: return @"Basketball";
        case HKWorkoutActivityTypeBowling: return @"Bowling";
        case HKWorkoutActivityTypeBoxing: return @"Boxing";
        case HKWorkoutActivityTypeClimbing: return @"Rock climbing";
        case HKWorkoutActivityTypeCricket: return @"Cricket";
        case HKWorkoutActivityTypeCrossTraining: return @"Cross trainer";
        case HKWorkoutActivityTypeCurling: return @"Curling"; //not supported
        case HKWorkoutActivityTypeCycling: return @"Bicycling";
        case HKWorkoutActivityTypeDance: return @"Dancing";
        case HKWorkoutActivityTypeDanceInspiredTraining: return @"Dancing";
        case HKWorkoutActivityTypeElliptical: return @"Elliptical";
        case HKWorkoutActivityTypeEquestrianSports: return @"Equestrian Sports";// not supported
        case HKWorkoutActivityTypeFencing: return @"Fencing";
        case HKWorkoutActivityTypeFishing: return @"Fishing";
        case HKWorkoutActivityTypeFunctionalStrengthTraining: return @"Functional Strength Training";
        case HKWorkoutActivityTypeGolf: return @"Golf";
        case HKWorkoutActivityTypeGymnastics: return @"Calisthenics";
        case HKWorkoutActivityTypeHandball: return @"Handball";//not supported
        case HKWorkoutActivityTypeHiking: return @"Hiking";
        case HKWorkoutActivityTypeHockey: return @"Hockey";
        case HKWorkoutActivityTypeHunting: return @"Hunting";
        case HKWorkoutActivityTypeLacrosse: return @"Lacrosse";
        case HKWorkoutActivityTypeMartialArts: return @"Tae Bo";
        case HKWorkoutActivityTypeMindAndBody: return @"Mind and Body";
        case HKWorkoutActivityTypeMixedMetabolicCardioTraining: return @"Cardio";
        case HKWorkoutActivityTypePaddleSports: return @"Paddle Sports";
        case HKWorkoutActivityTypePlay: return @"Play";// not supported
        case HKWorkoutActivityTypePreparationAndRecovery: return @"Preparation and Recovery";
        case HKWorkoutActivityTypeRacquetball: return @"Racquetball";
        case HKWorkoutActivityTypeRowing: return @"Rowing";
        case HKWorkoutActivityTypeRugby: return @"Rugby";
        case HKWorkoutActivityTypeRunning: return @"Running";
        case HKWorkoutActivityTypeSailing: return @"Sailing";
        case HKWorkoutActivityTypeSkatingSports: return @"Skating";
        case HKWorkoutActivityTypeSnowSports: return @"Snow Sports";
        case HKWorkoutActivityTypeSoccer: return @"Football";
        case HKWorkoutActivityTypeSoftball: return @"Softball";
        case HKWorkoutActivityTypeSquash: return @"Squash";
        case HKWorkoutActivityTypeStairClimbing: return @"Walking upstairs";
        case HKWorkoutActivityTypeSurfingSports: return @"Surfing";
        case HKWorkoutActivityTypeSwimming: return @"Swimming";
        case HKWorkoutActivityTypeTableTennis: return @"Table Tennis";
        case HKWorkoutActivityTypeTennis: return @"Tennis";
        case HKWorkoutActivityTypeTraditionalStrengthTraining: return @"Traditional Strength Training";
        case HKWorkoutActivityTypeVolleyball: return @"Volleyball";
        case HKWorkoutActivityTypeWalking: return @"Walking";
        case HKWorkoutActivityTypeWaterFitness: return @"Water Fitness";//not supported
        case HKWorkoutActivityTypeWaterPolo: return @"Water polo";
        case HKWorkoutActivityTypeWaterSports: return @"Waterskiing";
        case HKWorkoutActivityTypeWrestling: return @"Wrestling";
        case HKWorkoutActivityTypeYoga: return @"Yoga";
        default:
            return @"Unrecognized Workout";
    }
}
@end
