//
//  AddAlarmViewController.m
//  Custom Alarm
//
//  Created by Varsha on 05/02/14.
//  Copyright (c) 2014 Varsha. All rights reserved.
//

#import "AddAlarmViewController.h"
#import "AlarmViewController.h"

#define kDatePickerText 101
#define kSnoozeDurationText 102
#define kDayPickerAction 103
#define kSnoozeDurPickerAction 104
#define kAlarmText  105

@interface AddAlarmViewController (){
    NSArray *dayPickerOptions, *snoozeDurationOptions;
    IBOutlet UIDatePicker *datePicker;
    IBOutlet UIDatePicker *timePicker;
    IBOutlet UIScrollView *contentScrollView;
    IBOutlet UIView *containerView;
    
    NSDate  *selectedAlarmTime;
    NSDate  *selectedAlarmDate;
    NSDateFormatter *dateFormatter;
    UITextField *dayPickerText, *snoozeDurText, *alarmText;
}

- (IBAction)toggleDatePicker:(id)sender;
- (IBAction)cancelClick:(id)sender;
- (IBAction)doneClick:(id)sender;
@end

@implementation AddAlarmViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    selectedAlarmTime = timePicker.date;
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    selectedAlarmDate = datePicker.date;
    
    dayPickerText = (UITextField *)[self.view viewWithTag:kDatePickerText];
    dayPickerOptions = @[@"Today", @"Tomorrow", @"Day after tomorrow", @"A month from now!", @"A year from now!"];
    dayPickerText.text = [dateFormatter stringFromDate:selectedAlarmDate];
    
    snoozeDurText = (UITextField *)[self.view viewWithTag:kSnoozeDurationText];
    snoozeDurationOptions = @[@"5 min", @"10 min", @"15 min"];
    snoozeDurText.text = [snoozeDurationOptions objectAtIndex:0];
    
    alarmText = (UITextField *)[self.view viewWithTag:kAlarmText];
    
    [datePicker setMinimumDate:[NSDate date]];
    [datePicker addTarget:self action:@selector(updateDate) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelClick:(id)sender {
    [self performSegueWithIdentifier:@"backToAlarmList" sender:self];
}

/*
 * Save alarm object in data model, schedule notification
 */
- (IBAction)doneClick:(id)sender {
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *finalAlarmDate = [dayPickerText.text stringByAppendingFormat:@" %@", [dateFormatter stringFromDate:timePicker.date]];
    [dateFormatter setDateFormat:@"dd-MM-yyyy hh:mm a"];
    
    NSDate *alarmDate = [dateFormatter dateFromString:finalAlarmDate];
    NSDate *currentDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:[NSDate date]]];
    if ([alarmDate compare:currentDate] == NSOrderedDescending) {
        NSScanner *scanner = [NSScanner scannerWithString:snoozeDurText.text];
        [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] intoString:NULL];
        int duration;
        [scanner scanInt:&duration];
        
        NSManagedObjectContext *context = [self managedObjectContext];
        NSManagedObject *newAlarm = [NSEntityDescription
                                     insertNewObjectForEntityForName:@"Alarm"
                                     inManagedObjectContext:context];
        [newAlarm setValue:finalAlarmDate forKey:@"timeStamp"];
        [newAlarm setValue:[NSNumber numberWithInt:duration] forKey:@"snoozeDuration"];
        [newAlarm setValue:alarmText.text forKey:@"alarmText"];
        [newAlarm setValue:[NSNumber numberWithInt:self.alarmId] forKey:@"localNotificationId"];
        [self.alarmViewDelegate setAlarmId:self.alarmId++];
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
        [_alarmViewDelegate scheduleLocalNotification:alarmDate withText:alarmText.text];
        
        [self performSegueWithIdentifier:@"backToAlarmList" sender:self];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Wake Up!" message:@"Sorry, you can't set alarm for now/past time" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - Textfield delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField.tag == kDatePickerText) {
        if (![datePicker isHidden]) {
            [self toggleDatePicker:nil];
        }
        UIActionSheet *dayPicker = [[UIActionSheet alloc] initWithTitle:@"When do you want me to wake you up?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                    [dayPickerOptions objectAtIndex:0],
                                    [dayPickerOptions objectAtIndex:1],
                                    [dayPickerOptions objectAtIndex:2],
                                    [dayPickerOptions objectAtIndex:3],
                                    [dayPickerOptions objectAtIndex:4],
                                    nil];
        dayPicker.tag = kDayPickerAction;
        [dayPicker showInView:[UIApplication sharedApplication].keyWindow];
        return NO;
    } else if (textField.tag == kSnoozeDurationText){
        UIActionSheet *snoozeDurPicker = [[UIActionSheet alloc] initWithTitle:@"How long should I be silent?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                          [snoozeDurationOptions objectAtIndex:0],
                                          [snoozeDurationOptions objectAtIndex:1],
                                          [snoozeDurationOptions objectAtIndex:2],
                                          nil];
        snoozeDurPicker.tag = kSnoozeDurPickerAction;
        [snoozeDurPicker showInView:[UIApplication sharedApplication].keyWindow];
        return NO;
    } else if (textField.tag == kAlarmText){
        [contentScrollView setContentOffset:CGPointMake(0,textField.center.y+20) animated:YES];
        [contentScrollView setContentSize:CGSizeMake(contentScrollView.frame.size.width, contentScrollView.frame.size.height + 120)];
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == kAlarmText){
        [contentScrollView setContentSize:CGSizeMake(contentScrollView.frame.size.width, contentScrollView.frame.size.height - 120)];
        [contentScrollView setContentOffset:CGPointMake(0,-30) animated:YES];
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)updateDate{
    dayPickerText.text = [dateFormatter stringFromDate:[datePicker date]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == kDayPickerAction) {
        NSDateComponents *dateComponent = [[NSDateComponents alloc] init];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        [calendar setTimeZone:[NSTimeZone localTimeZone]];
        switch (buttonIndex) {
            case 0:
                dateComponent.day = 0;
                break;
            case 1:
                dateComponent.day = 1;
                break;
            case 2:
                dateComponent.day = 2;
                break;
            case 3:
                dateComponent.month = 1;
                break;
            case 4:
                dateComponent.year = 1;
                break;
            default:
                break;
        }
        selectedAlarmDate = [calendar dateByAddingComponents:dateComponent toDate:[NSDate date] options:0];
        dayPickerText.text = [dateFormatter stringFromDate:selectedAlarmDate];
    } else if(actionSheet.tag == kSnoozeDurPickerAction){
        switch (buttonIndex) {
            case 0:
                snoozeDurText.text = [snoozeDurationOptions objectAtIndex:0];
                break;
            case 1:
                snoozeDurText.text = [snoozeDurationOptions objectAtIndex:1];
                break;
            case 2:
                snoozeDurText.text = [snoozeDurationOptions objectAtIndex:2];
                break;
            default:
                break;
        }
    }
}

- (IBAction)toggleDatePicker:(id)sender {
    if (datePicker.isHidden) {
        [UIView animateWithDuration:.5
                              delay:0.0
                            options:UIViewAnimationOptionTransitionCurlDown
                         animations:^{
                             containerView.frame = CGRectMake(containerView.frame.origin.x, containerView.frame.origin.y + datePicker.frame.size.height, containerView.frame.size.width, containerView.frame.size.height);
                             contentScrollView.contentSize = CGSizeMake(contentScrollView.frame.size.width, contentScrollView.frame.size.height + datePicker.frame.size.height + 10);
                         }
                         completion:^(BOOL finished) {
                             datePicker.hidden = NO;
                         }];
        [dateFormatter setDateFormat:@"dd-MM-yyyy"];
        dayPickerText.text = [dateFormatter stringFromDate:[datePicker date]];
    } else {
        [UIView animateWithDuration:.5
                              delay:0.0
                            options:UIViewAnimationOptionTransitionCurlUp
                         animations:^{
                             datePicker.hidden = YES;
                             containerView.frame = CGRectMake(containerView.frame.origin.x, containerView.frame.origin.y - datePicker.frame.size.height, containerView.frame.size.width, containerView.frame.size.height);
                             contentScrollView.contentSize = CGSizeMake(contentScrollView.frame.size.width, contentScrollView.frame.size.height - datePicker.frame.size.height - 10);
                         }
                         completion:^(BOOL finished) {
                         }];
    }
}

@end
