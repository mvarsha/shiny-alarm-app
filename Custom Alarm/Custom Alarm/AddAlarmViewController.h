//
//  AddAlarmViewController.h
//  Custom Alarm
//
//  Created by Varsha on 05/02/14.
//  Copyright (c) 2014 Varsha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddAlarmViewController : UIViewController<UIActionSheetDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) int alarmId;
@property (nonatomic, strong) id alarmViewDelegate;

@end
