//
//  AppDelegate.h
//  gongdanApp
//
//  Created by 薛翔 on 14-2-20.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong)UITabBarController *tabbarController;
@property (nonatomic, copy)NSString *loginedUserName;
@property (nonatomic, copy)NSString *userGroup;
@property (nonatomic, copy)NSString *userGroupId;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
