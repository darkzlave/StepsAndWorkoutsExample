//
//  SecondViewController.m
//  CocoaheadsHealthKit
//
//  Created by Phillipe Casorla Sagot on 23/11/14.
//  Copyright (c) 2014 PCS. All rights reserved.
//

#import "PCWorkoutsViewController.h"
#import "PCHealthCoordinator.h"
#import "PCWorkoutTableViewCell.h"
#import "PCExerciseData.h"
#import "POP.h"

@interface PCWorkoutsViewController () <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *workoutsTable;
@property (weak, nonatomic) IBOutlet UILabel *totalCaloriesLabel;
@property (weak, nonatomic) IBOutlet UIButton *enableButton;

@property (strong, nonatomic) NSArray *workouts;

- (IBAction)enableWorkouts:(id)sender;

@end

@implementation PCWorkoutsViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self  = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadWorkoutsData:) name:PCHealthWorkoutsLoaded object:nil];
    }
    return  self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UINib *nib2 = [UINib nibWithNibName:[PCWorkoutTableViewCell identifier] bundle:nil];
    [self.workoutsTable registerNib:nib2 forCellReuseIdentifier:[PCWorkoutTableViewCell identifier]];
    [self.workoutsTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    if ([PCHealthCoordinator isWorkoutsEnabled]) {
        [self loadTableWithWorkoutsData:[[PCHealthCoordinator sharedCoordinator] workoutsForToday]];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    if ([PCHealthCoordinator isWorkoutsEnabled]) {
        self.enableButton.alpha = 0;
        self.workoutsTable.alpha = 1;
        self.totalCaloriesLabel.alpha = 1;
    } else {
        self.enableButton.alpha = 1;
        self.workoutsTable.alpha = 0;
        self.totalCaloriesLabel.alpha = 0;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)enableWorkouts:(id)sender {
    [[PCHealthCoordinator sharedCoordinator] readDataFromWorkouts:NO];
}

-(void) loadWorkoutsData:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadTableWithWorkoutsData:notification.object];
    });
}

-(void) loadTableWithWorkoutsData:(NSArray*)workouts{
    self.workouts = workouts;
    
    double total = 0;
    for (PCExerciseData *exe in _workouts) {
        total += exe.calories;
    }
    total = floorf(total);
    self.totalCaloriesLabel.text = [NSString stringWithFormat:@"%.0f",total];
    
    POPSpringAnimation *forwardAnimation = [POPSpringAnimation animation];
    forwardAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewScaleXY];
    forwardAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(1.0f, 1.0f)];
    forwardAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1.2f,1.2f)];
    forwardAnimation.springBounciness = 20.0f;
    forwardAnimation.springSpeed = 40.0f;
    [self.totalCaloriesLabel pop_addAnimation:forwardAnimation forKey:@"jumpAnimation"];
    
    [self.workoutsTable reloadData];
}
#pragma mark - Table datasource/delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _workouts.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PCWorkoutTableViewCell *cell = [self.workoutsTable dequeueReusableCellWithIdentifier:[PCWorkoutTableViewCell identifier]];
    PCExerciseData *workout = self.workouts[indexPath.row];
    cell.nameLabel.text = workout.name;
    
    NSEnergyFormatter *energyFormatter = [self energyFormatter];

    cell.caloriesLabel.text = [energyFormatter stringFromValue:workout.calories unit:NSEnergyFormatterUnitKilocalorie];
    cell.timeLabel.text = [NSString stringWithFormat:@"%.0f min",workout.time];
    cell.distanceLabel.text = [NSString stringWithFormat:@"%.1f Km",workout.distance];
    
    return cell;
}
#pragma mark - Convenience

- (NSEnergyFormatter *)energyFormatter {
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
