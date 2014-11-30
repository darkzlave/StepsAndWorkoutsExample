//
//  FirstViewController.m
//  CocoaheadsHealthKit
//
//  Created by Phillipe Casorla Sagot on 23/11/14.
//  Copyright (c) 2014 PCS. All rights reserved.
//

#import "PCStepsViewController.h"
#import "PCHealthCoordinator.h"
#import "PCExerciseData.h"
#import "POP.h"

@interface PCStepsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *stepsLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *caloriesLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *enableButton;
@property (weak, nonatomic) IBOutlet UILabel *todayDescription;

- (IBAction)enableSteps:(id)sender;
@end

@implementation PCStepsViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self  = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadStepsData:) name:PCHealthStepsLoaded object:nil];
    }
    return  self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    if ([PCHealthCoordinator isStepsEnabled]) {
        [self loadLabelsWithData:[[PCHealthCoordinator sharedCoordinator] stepsForToday]];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    if ([PCHealthCoordinator isStepsEnabled]) {
        self.enableButton.alpha = 0;
        self.stepsLabel.alpha = 1;
        self.distanceLabel.alpha = 1;
        self.caloriesLabel.alpha = 1;
        self.timeLabel.alpha = 1;
        self.todayDescription.alpha = 1;
    } else {
        self.enableButton.alpha = 1;
        self.stepsLabel.alpha = 0;
        self.distanceLabel.alpha = 0;
        self.caloriesLabel.alpha = 0;
        self.timeLabel.alpha = 0;
        self.todayDescription.alpha = 0;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)enableSteps:(id)sender
{
    [[PCHealthCoordinator sharedCoordinator] startTrackingSteps:NO];
}

-(void) loadStepsData:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        PCExerciseData *exeData = notification.object;
        [self loadLabelsWithData:exeData];
    });
}

-(void) loadLabelsWithData:(PCExerciseData*)exeData
{
    NSEnergyFormatter *energyFormatter = [self energyFormatter];
    
    self.caloriesLabel.text = [energyFormatter stringFromValue:[exeData stepsCaloriesWithWeight:64] unit:NSEnergyFormatterUnitKilocalorie];
    
    self.distanceLabel.text = [NSString stringWithFormat:@"%.1f KM",exeData.distance];
    
    self.stepsLabel.text = [NSString stringWithFormat:@"%li",(long)exeData.steps];
    
    self.timeLabel.text = [NSString stringWithFormat:@"%.0f min",exeData.time];
    
    POPSpringAnimation *forwardAnimation = [POPSpringAnimation animation];
    forwardAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewScaleXY];
    forwardAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(1.0f, 1.0f)];
    forwardAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1.2f,1.2f)];
    forwardAnimation.springBounciness = 20.0f;
    forwardAnimation.springSpeed = 40.0f;
    [self.stepsLabel pop_addAnimation:forwardAnimation forKey:@"jumpAnimation"];
}

#pragma mark - Convenience

- (NSEnergyFormatter *)energyFormatter
{
    static NSEnergyFormatter *energyFormatter;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        energyFormatter = [[NSEnergyFormatter alloc] init];
        energyFormatter.unitStyle = NSFormattingUnitStyleLong;
        energyFormatter.forFoodEnergyUse = YES;
        energyFormatter.numberFormatter.maximumFractionDigits = 2;
    });
    
    return energyFormatter;
}
-(BOOL)prefersStatusBarHidden{
    return YES;
}
-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
