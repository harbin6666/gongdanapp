//
//  AppDelegate.h
//  gongdanApp
//
//  Created by 薛翔 on 14-2-20.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MQTTKit.h"
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong)UITabBarController *tabbarController;
@property (nonatomic, copy)NSString *loginedUserName,*userZhName;
@property (nonatomic, copy)NSString *userGroup;
@property (nonatomic, copy)NSString *userGroupId;
@property (nonatomic, assign)BOOL reject;//驳回权限
@property (nonatomic, strong)NSNumber *todoFreshTime;
@property (nonatomic, strong)NSString *userTelNum;
@property (nonatomic, strong)NSString *dept,*company;
@property (nonatomic, strong)AVAudioPlayer *audioPlayer;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
-(void)freshTimer;
-(void)mqtt;
@end
