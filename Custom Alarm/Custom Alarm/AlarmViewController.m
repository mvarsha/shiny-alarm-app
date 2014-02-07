//
//  AlarmViewController.m
//  Custom Alarm
//
//  Created by Varsha on 05/02/14.
//  Copyright (c) 2014 Varsha. All rights reserved.
//

#import "AlarmViewController.h"
#import "AddAlarmViewController.h"

@interface AlarmViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation AlarmViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.alarmId = 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        NSManagedObject *object =[self.fetchedResultsController objectAtIndexPath:indexPath];
        [self deleteNotificationWithId:(NSNumber*)[object valueForKey:@"localNotificationId"]];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"addAlarm"]) {
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        [[segue destinationViewController] setAlarmId:self.alarmId];
        [[segue destinationViewController] setAlarmViewDelegate:self];
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Alarm" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[object valueForKey:@"timeStamp"] description];
    cell.detailTextLabel.text = [[object valueForKey:@"alarmText"] description];
}

- (IBAction)backToAlarmList:(UIStoryboardSegue *)segue {
}

#pragma mark - Local Notification

/*
 * Set Notification
 */
-(void)scheduleLocalNotification:(NSDate *)alarmDate withText:alarmText{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = alarmDate;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.alertBody = alarmText;
    if ([alarmText isEqualToString:@""]) {
        localNotification.alertBody = @"Alarm";
    }
    localNotification.alertAction = NSLocalizedString(@"View details", nil);
    [localNotification setHasAction: YES];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    NSDictionary *localNotificationIdInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:self.alarmId] forKey:@"localNotificationId"];
    localNotification.userInfo = localNotificationIdInfo;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

/*
 * Delete Notification
 */
-(void)deleteNotificationWithId:(NSNumber *)localNotificationId{
    UIApplication *application = [UIApplication sharedApplication];
    NSArray *localNots = [application scheduledLocalNotifications];
    for (UILocalNotification *localNotification in localNots) {
        NSDictionary *localNotificationInfo = localNotification.userInfo;
        NSNumber *notificationId=[localNotificationInfo valueForKey:@"localNotificationId"];
        if (notificationId == localNotificationId)
        {
            [application cancelLocalNotification:localNotification];
            break;
        }
    }
}

/*
 * Received Notification
 */
-(void)receivedNotification:(UILocalNotification *)notification{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Wake Up!" message:notification.alertBody delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Snooze", nil];
    alert.tag = [(NSNumber*)[notification.userInfo valueForKey:@"localNotificationId"] intValue];
    [alert show];
    [[UIApplication sharedApplication] cancelLocalNotification:notification];
}

/*
 * Snooze, dismiss action
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Alarm" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"localNotificationId == %d", alertView.tag];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
	NSArray *array = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(array == nil) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
    if ([array count] > 0) {
        NSManagedObject *alarm = [array objectAtIndex:0];
        if (buttonIndex == 0 ) {
            [self.managedObjectContext deleteObject:alarm];
        } else if(buttonIndex == 1) {
            NSString *date = [alarm valueForKey:@"timeStamp"];
            NSInteger snoozeDuration = [[alarm valueForKey:@"snoozeDuration"]integerValue];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"dd-MM-yyyy hh:mm a"];
            [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
            NSDateComponents *dateComponent = [[NSDateComponents alloc] init];
            dateComponent.minute = snoozeDuration;
            NSCalendar *calendar = [NSCalendar currentCalendar];
            [calendar setTimeZone:[NSTimeZone localTimeZone]];
            NSDate *selectedDate = [calendar dateByAddingComponents:dateComponent toDate:[dateFormatter dateFromString:date] options:0];
            [self scheduleLocalNotification:selectedDate withText:[alarm valueForKey:@"alarmText"]];
            [alarm setValue:[dateFormatter stringFromDate:selectedDate] forKey:@"timeStamp"];
            [self.managedObjectContext save:&error];
        }
    }
}

@end
