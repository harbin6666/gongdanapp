//
//  AppDelegate.m
//  gongdanApp
//
//  Created by 薛翔 on 14-2-20.
//  Copyright (c) 2014年 xuexiang. All rights reserved.
//

#import "AppDelegate.h"
#import "GDBasedNC.h"
#import "GDWaitTodoVC.h"
#import "GDCopyVC.h"
#import "GDDoneVC.h"
#import "GDSearchVC.h"
#import "GDMainHandleVC.h"
#define kMQTTServerHost @"120.202.255.76"
@interface AppDelegate()<UIAlertViewDelegate,AVAudioPlayerDelegate>
@property(nonatomic,strong)GDWaitTodoVC *vc1;
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,strong)NSDictionary*pushDic;
@property(nonatomic,assign)int counter;
@property(nonatomic,assign)BOOL interruptedWhilePlaying;
@end
@implementation AppDelegate
//static MQTTClient *client=nil;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
#pragma mark mqtt
/*
-(void)mqtt{
    return;
    
    if (self.loginedUserName==nil||[self.loginedUserName isEqualToString:@""]) {
        return;
    }
    NSString *clientID = [UIDevice currentDevice].identifierForVendor.UUIDString;
//    if (self.client!=nil) {
//        [self.client disconnectWithCompletionHandler:^(NSUInteger code) {
//            self.client=nil;
//        }];        
//    }
    NSLog(@"%@",client);
    if (client==nil) {
        NSLog(@"new connect!!!!!!!");
        client = [[MQTTClient alloc] initWithClientId:[NSString stringWithFormat:@"trackW/%@",clientID]];
        client.username=@"admin";
        client.password=@"123456a?";
    

    __block __weak typeof(self) weakself=self;
    // define the handler that will be called when MQTT messages are received by the client
    [client setMessageHandler:^(MQTTMessage *message) {
        typeof(weakself)self=weakself;
        // Any update to the UI must be done on the main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            if (message.payload!=nil) {
                NSDictionary* result=[NSJSONSerialization JSONObjectWithData:message.payload options:0 error:nil];
                if (result!=nil) {
                    [self addLocalNotify:result];
                }
            }
        });
    }];
    NSLog(@" self.client.connected=%d\n",client.connected);
    // connect the MQTT client
    [client connectToHost:kMQTTServerHost completionHandler:^(MQTTConnectionReturnCode code) {
        if (code == ConnectionAccepted) {
            // The client is connected when this completion handler is called
            NSLog(@"client is connected with id %@", clientID);
//            NSLog(@"self.client.connected=%d\n\n\n",self.client.connected);
            // Subscribe to the topic
            [client subscribe:[NSString stringWithFormat:@"trackW/%@",self.loginedUserName] withCompletionHandler:^(NSArray *grantedQos) {
                // The client is effectively subscribed to the topic when this completion handler is called
                NSLog(@"subscribed to topic %@", self.loginedUserName);
            }];
        }
    }];
    }
}

-(void)handleInterruption:(NSNotification*)notification{
    NSError* audioSessionError=nil;
    NSDictionary *interruptionDictionary = [notification userInfo];
    NSNumber *interruptionType = (NSNumber *)[interruptionDictionary valueForKey:AVAudioSessionInterruptionTypeKey];
    if (self.interruptedWhilePlaying) {
        self.interruptedWhilePlaying=NO;
        [self.audioPlayer play];
        if (client!=nil&&client.connected==NO) {
            [client reconnect];
        }
        [[AVAudioSession sharedInstance] setActive:YES error:&audioSessionError];
    }

    if ([interruptionType intValue] == AVAudioSessionInterruptionTypeBegan) {
        NSLog(@"Interruption started");
        self.interruptedWhilePlaying = YES;
        [self.audioPlayer pause];
        [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&audioSessionError];

    } else if ([interruptionType intValue] == AVAudioSessionInterruptionTypeEnded){
        NSLog(@"Interruption ended");
            self.interruptedWhilePlaying=NO;
            [self.audioPlayer play];
        if (client!=nil&&client.connected==NO) {
            [client reconnect];
        }
    } else {
        NSLog(@"Something else happened");
    }
    

}

void interruptionListenerCallback ( void *inUserData,  UInt32  interruptionState ) {
    if (interruptionState == kAudioSessionBeginInterruption) {
//        if ([SharedDelegate audioPlayer]) {
            [[SharedDelegate audioPlayer] pause];
//        }
    } else if (interruptionState == kAudioSessionEndInterruption) {
        [[SharedDelegate audioPlayer] play];
    }
}

-(void)playsoundForever{
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleInterruption:)
                                                 name: AVAudioSessionInterruptionNotification
                                               object: [AVAudioSession sharedInstance]];

    
    //    AVAudioPlayer *userData=self.audioPlayer;
    //    AudioSessionInitialize ( NULL, NULL, interruptionListenerCallback, &userData);

    if (self.audioPlayer.playing&&self.audioPlayer!=nil) {
        return;
    }
    dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(dispatchQueue, ^(void) {
        NSError *audioSessionError = nil;
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:YES error:&audioSessionError];
        if ([audioSession setCategory:AVAudioSessionCategoryPlayback error:&audioSessionError]){
            NSLog(@"Successfully set the audio session.");
        } else {
            NSLog(@"Could not set the audio session");
        }
        
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *filePath = [mainBundle pathForResource:@"mysong" ofType:@"mp3"];
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        NSError *error = nil;
        
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData error:&error];
        
        if (self.audioPlayer != nil){
            self.audioPlayer.delegate = self;
            [self.audioPlayer setVolume:0];

            [self.audioPlayer setNumberOfLoops:-1];
            if ([self.audioPlayer prepareToPlay] && [self.audioPlayer play]){
                NSLog(@"Successfully started playing...");
            } else {
                NSLog(@"Failed to play.");
            }
        } else {
            
        }
    });
}
- (void)backgroundHandler {
    NSLog(@"### -->backgroundinghandler");
    UIApplication*    app = [UIApplication sharedApplication];
   __block UIBackgroundTaskIdentifier bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
       NSLog(@"### -->endBackgroundTask");
        [app endBackgroundTask:bgTask];
        
        bgTask=UIBackgroundTaskInvalid;
        
    }];
    // Start the long-running task
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Running in the background\n");
        while (1) {
            NSLog(@"Background time Remaining: %f",[app backgroundTimeRemaining]);
            NSLog(@"counter:%d", self.counter++);
            if (self.counter%10==0) {
                [self mqtt];
            }
            sleep(1);
        }
        
    });
    
}
-(void)addLocalNotify:(NSDictionary*)dic{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.userInfo=dic;
    // 设置notification的属性
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1]; //出发时间
    localNotification.alertBody = dic[@"FormNo"]; // 消息内容
    localNotification.repeatInterval = 0; // 重复的时间间隔
    localNotification.soundName = UILocalNotificationDefaultSoundName; // 触发消息时播放的声音
    localNotification.applicationIconBadgeNumber = 1; //应用程序Badge数目
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification]; //注册

}
 */
#pragma mark mqtt
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.vc1 = [[GDWaitTodoVC alloc]init];
    GDBasedNC *nc1 = [[GDBasedNC alloc]initWithRootViewController:self.vc1];
    nc1.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"待办工单" image:[UIImage imageNamed:@"item1"] tag:0];//[UIImage imageNamed:@"backlog_normal"] tag:0];
    
    GDCopyVC *vc2 = [[GDCopyVC alloc]init];
    GDBasedNC *nc2 = [[GDBasedNC alloc]initWithRootViewController:vc2];
    nc2.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"抄送工单" image:[UIImage imageNamed:@"item2"] tag:0];
    
    GDDoneVC *vc3 = [[GDDoneVC alloc]init];
    GDBasedNC *nc3 = [[GDBasedNC alloc]initWithRootViewController:vc3];
    nc3.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"已办工单" image:[UIImage imageNamed:@"tabbar_IT"] tag:0];//[UIImage 
    
    GDSearchVC *vc4 = [[GDSearchVC alloc]init];
    GDBasedNC *nc4 = [[GDBasedNC alloc]initWithRootViewController:vc4];
    nc4.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"查询工单" image:[UIImage imageNamed:@"item3"] tag:0];
    
    self.tabbarController = [[UITabBarController alloc]init];
    self.tabbarController.viewControllers = @[nc1, nc2, nc3, nc4];
    
    [[UITabBar appearance]setBackgroundImage:[UIImage imageNamed:@"tab_bg"]];
    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"tab_bg_main_pressed"]];
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor whiteColor]];
    
    [self.tabbarController.tabBar setTintColor:[UIColor colorWithRed:57.0/255 green:237.0/255 blue:231.0/255 alpha:1.0]];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"topbar"] forBarMetrics:UIBarMetricsDefault];
//    [[UITabBar appearance] setBarTintColor:[UIColor clearColor]];
    
//    UITabBarItem *item = [self.tabbarController.tabBar.items objectAtIndex:0];
//    item.image = [UIImage imageNamed:@"backlog_normal"];
    
    self.window.rootViewController = self.tabbarController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    
//    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
//    {
//        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
//    }
    
    

//    [self playsoundForever];
    [self.window makeKeyAndVisible];
//    [self addLocalNotify:@{@"FormNo":@"HB-051-150127-23118",@"FormStatus" : @"2",@"OutTimeStatus" : @0,@"Result":@[@{@"Key":@"工单编号",@"Value":@"HB-051-141014-22149"},@{@"Key":@"工单主题",@"Value":@"测试"},@{@"Key":@"处理时限",@"Value":@"2014-10-15 13:52:26"}]}];
    return YES;
}

-(void)freshTimer{
    self.timer=[NSTimer scheduledTimerWithTimeInterval:self.todoFreshTime.integerValue target:self.vc1 selector:@selector(getData) userInfo:nil repeats:YES];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

//    BOOL backgroundAccepted = [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{
//        NSLog(@"backgrounding accepted");
//        [self backgroundHandler];
//    }];
//    if (backgroundAccepted)
//    {
//    }
//    [self backgroundHandler];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
//    if (self.audioPlayer.playing==NO) {
//        self.interruptedWhilePlaying=NO;
//        [self.audioPlayer play];
//        if (client!=nil&&client.connected==NO) {
//            [client reconnect];
//        }
//    }

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}
#pragma mark local notify
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    self.pushDic=notification.userInfo;
    notification.applicationIconBadgeNumber=0;
    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
   UIAlertView* alert= [[UIAlertView alloc] initWithTitle:@"新的工单" message:notification.alertBody delegate:self cancelButtonTitle:@"忽略" otherButtonTitles:@"查看", nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        
        NSString *formNo = [self.pushDic objectForKey:@"FormNo"];
        NSNumber *formState = [self.pushDic objectForKey:@"FormStatus"];
        
        GDMainHandleVC *hvc = [[GDMainHandleVC alloc]initWithFormNo:formNo formType:FormType_todo formsearchState:FormSearchState_TodoAndDoing formState:formState.intValue];
        hvc.hidesBottomBarWhenPushed = YES;
        GDBasedNC *selectNc=(GDBasedNC*)self.tabbarController.selectedViewController;
        [selectNc.topViewController.navigationController pushViewController:hvc animated:YES];
    }
}
#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"gongdanApp" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"gongdanApp.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
