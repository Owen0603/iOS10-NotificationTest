//
//  NotificationService.m
//  NotificationServer
//
//  Created by 姚凤 on 16/9/30.
//  Copyright © 2016年 姚凤. All rights reserved.
//

#import "NotificationService.h"
#import <UIKit/UIKit.h>

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.title];
    
    NSDictionary *apsDict = [request.content.userInfo objectForKey:@"aps"];
    NSString *acttchUrl = [apsDict objectForKey:@"image"];
    
    //此处可以修改部分内容，比喻从网络下载一些图片
//    UIImage *imageFromUrl = [self getImageFromURL:acttchUrl];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirctoryPath = [paths objectAtIndex:0];
//    
//    NSString *localpath = [self saveImage:imageFromUrl withFileName:@"image1" ofType:@"png" inDirectory:documentsDirctoryPath];
//    if (localpath && ![localpath isEqualToString:@""]) {
//        UNNotificationAttachment *attach = [UNNotificationAttachment attachmentWithIdentifier:@"photo" URL:[NSURL URLWithString:[@"file://" stringByAppendingString:localpath]] options:nil error:nil];
//        if(attach)
//        {
//            self.bestAttemptContent.attachments = @[attach];
//        }
//    }
//    self.contentHandler(self.bestAttemptContent);
    
    
    //另一种方式
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:acttchUrl];
    
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url
                                                        completionHandler:^(NSURL * _Nullable location,
                                                                            NSURLResponse * _Nullable response,
                                                                            NSError * _Nullable error) {
                                                            NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
                                                            // response.suggestedFilename ： 建议使用的文件名，一般跟服务器端的文件名一致
                                                            NSString *file = [caches stringByAppendingPathComponent:response.suggestedFilename];
                                                            
                                                            // 将临时文件剪切或者复制Caches文件夹
                                                            NSFileManager *mgr = [NSFileManager defaultManager];
                                                            
                                                            // AtPath : 剪切前的文件路径
                                                            // ToPath : 剪切后的文件路径
                                                            [mgr moveItemAtPath:location.path toPath:file error:nil];
                                                            
                                                            if (file && ![file  isEqualToString: @""])
                                                            {
                                                                UNNotificationAttachment *attch= [UNNotificationAttachment attachmentWithIdentifier:@"photo"
                                                                                                                                                URL:[NSURL URLWithString:[@"file://" stringByAppendingString:file]]
                                                                                                                                            options:nil
                                                                                                                                              error:nil];
                                                                if(attch)
                                                                {
                                                                    self.bestAttemptContent.attachments = @[attch];
                                                                }
                                                            }
                                                            self.contentHandler(self.bestAttemptContent);
                                                        }];
    [downloadTask resume];

}

- (UIImage *) getImageFromURL:(NSString *)fileURL {
    //    NSString *mockUrl = @"http://upload-images.jianshu.io/upload_images/1290592-0bb04aa98649aecf.png";
    //    NSString *mockUrl = @"https://picjumbo.imgix.net/HNCK8461.jpg?q=40&w=200&sharp=30";
    NSLog(@"执行图片下载函数");
    UIImage * result;
    //dataWithContentsOfURL方法需要https连接
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    
    return result;
}

- (NSString *)saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extentsion inDirectory:(NSString *)directoryPath{
    NSString *urlString = @"";
    if ([[extentsion lowercaseString] isEqualToString:@"png"]) {
        urlString = [directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",imageName,@"png"]];
        [UIImagePNGRepresentation(image) writeToFile:urlString options:NSAtomicWrite error:nil];
    }else if ([[extentsion lowercaseString] isEqualToString:@"jpg"] ||
              [[extentsion lowercaseString] isEqualToString:@"jpeg"])
    {
        urlString = [directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]];
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:urlString options:NSAtomicWrite error:nil];
    } else
    {
        NSLog(@"extension error");
    }
    return urlString;
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
