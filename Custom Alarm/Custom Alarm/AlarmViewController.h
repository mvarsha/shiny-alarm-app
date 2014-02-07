//
//  AlarmViewController.h
//  Custom Alarm
//
//  Created by Varsha on 05/02/14.
//  Copyright (c) 2014 Varsha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AlarmViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) int alarmId; //Unique ID assigned to each alarm object

- (IBAction)backToAlarmList:(UIStoryboardSegue *)segue;
-(void)scheduleLocalNotification:(NSDate *)alarmDate withText:alarmText;
-(void)receivedNotification:(UILocalNotification *)notification;
@end
