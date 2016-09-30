//
//  AppDelegate.m
//  Test10Notification
//
//  Created by 姚凤 on 16/9/29.
//  Copyright © 2016年 姚凤. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    //通知认证
    //UNAuthorizationOptionCarPlay 特殊一条
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            NSLog(@"授权成功");
        }
    }];
    
    //获取授权时用户的点击事件
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        NSLog(@"user setting:%@",settings);
    }];
    
    
//1、**************************************注册远程通知**************************************
//    通知payload
//    {
//        @"aps" : {
//            @"alert" : {
//                @"title" : @"一行显示，多余省略号",
//                @"subtitle" : @"一行显示，多余省略号",
//                @"body" : @"2行显示，多余省略号"
//            },
//            @"badge" : 1
//        },
//    }
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    
    
    
    
//2、**************************************注册本地通知**************************************
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"Test";
    content.subtitle = @"Test 10 notification";
    content.body = @".....";
    content.badge = @(1);
    //附件
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"appicon" withExtension:@"png"];
    UNNotificationAttachment *attach = [UNNotificationAttachment attachmentWithIdentifier:@"identifier" URL:url options:nil error:nil];
    content.attachments = @[attach];
    
    
    //本地通知新功能
//    UNTimeIntervalNotificationTrigger //间隔
//    UNCalendarNotificationTrigger     //日历
//    UNLocationNotificationTrigger   //区域
    //1、时间通知
    UNTimeIntervalNotificationTrigger *interval = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:75 repeats:true];  //5秒通知
    
    //2.日历通知
    NSDateComponents *componet = [[NSDateComponents alloc] init];
    componet.weekOfYear = 4;
    UNCalendarNotificationTrigger *calendar = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:componet repeats:true];
    
    
    //3.区域通知
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter: CLLocationCoordinate2DMake(26.336164, 52.030018) radius:kCLLocationAccuracyBest identifier:@"testRegion"];
    UNLocationNotificationTrigger *local = [UNLocationNotificationTrigger triggerWithRegion:region repeats:true];
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"interval" content:content trigger:interval];  // 5s推送一个本地通知
    
    //注册此通知
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        
    }];
    
    
    
//3、**************************************通知事件**************************************
    UNNotificationAction *action1 = [UNNotificationAction actionWithIdentifier:@"action1" title:@"进入应用" options:UNNotificationActionOptionForeground];
    UNNotificationAction *action2 = [UNNotificationAction actionWithIdentifier:@"action2" title:@"忽略" options:UNNotificationActionOptionForeground];

    UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:@"category1" actions:@[action1,action2] intentIdentifiers:@[@"action1",@"action2"] options:UNNotificationCategoryOptionNone];
    
    [center setNotificationCategories:[NSSet setWithObject:category]];
    

    
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma  mark--通知中心的代理


- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    
}

//收到通知还未展示时调用，可以做一些简单的本地处理
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    
}

@end
