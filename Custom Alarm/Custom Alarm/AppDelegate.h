//
//  AppDelegate.h
//  Custom Alarm
//
//  Created by Varsha on 05/02/14.
//  Copyright (c) 2014 Varsha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlarmViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) AlarmViewController *controller;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
