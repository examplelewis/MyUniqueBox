//
//  AppDelegate.m
//  MyUniqueBox
//
//  Created by 龚宇 on 2020/9/11.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "AppDelegate.h"

#import "MUBDownloadSettingManager.h"
#import "MUBExceptionManager.h"
#import "MUBMenuItemManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    [[MUBSettingManager defaultManager] updatePreferences];
    [[MUBDownloadSettingManager defaultManager] updatePreferences];
    [[MUBDownloadSettingManager defaultManager] updateMenuItems];
    
    [self setupLogger];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetWeiboToken:) name:MUBDidGetWeiboTokenNotification object:nil];
}
- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleAppleEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES; //点击窗口左上方的关闭按钮退出应用程序
}

#pragma mark - MenuItem Action
- (IBAction)customMenuItemDidPress:(NSMenuItem *)sender {
    [MUBMenuItemManager customMenuItemDidPress:sender];
}

#pragma mark - Setup
- (void)setupLogger {
    // 在系统上保持一周的日志文件
    DDLogFileManagerDefault *logFileManager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:[MUBSettingManager defaultManager].mainFolderPath];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:logFileManager];
    fileLogger.rollingFrequency = 60 * 60 * 24 * 7;
    fileLogger.logFileManager.maximumNumberOfLogFiles = 3;
    fileLogger.maximumFileSize = 10 * 1024 * 1024;
    [DDLog addLogger:fileLogger];
    
    // RELEASE 的时候不需要添加 console 日志，只保留文件日志
#ifdef DEBUG
    [DDLog addLogger:[DDOSLogger sharedInstance]]; // console 日志
#endif
}

#pragma mark - Notification
- (void)didGetWeiboToken:(NSNotification *)notification {
    for (NSWindow *window in [NSApplication sharedApplication].windows) {
        if (![window.windowController isMemberOfClass:[NSWindowController class]]) {
            [window close];
            
            break;
        }
    }
    
//    [self processWeiboToken:(NSString *)notification.object];
}

#pragma mark - Other
- (void)handleAppleEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
//    NSString *urlString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
//    [self processWeiboToken:[urlString componentsSeparatedByString:@"code="].lastObject];
}
//- (void)processWeiboToken:(NSString *)token {
//    [MRBUserManager defaultManager].weibo_code = token;
//    [[MRBUserManager defaultManager] saveAuthDictIntoPlistFile];
//
//    [[MRBHttpManager sharedManager] getWeiboTokenWithStart:nil success:^(NSDictionary *dic) {
//        [MRBUserManager defaultManager].weibo_token = dic[@"access_token"];
//        [MRBUserManager defaultManager].weibo_expires_at_date = [NSDate dateWithTimeIntervalSinceNow:[dic[@"expire_in"] integerValue]];
//        [[MRBUserManager defaultManager] saveAuthDictIntoPlistFile];
//
//        [[MRBLogManager defaultManager] showLogWithFormat:@"成功获取到Token信息：%@", dic];
//    } failed:^(NSString *errorTitle, NSString *errorMsg) {
//        MRBAlert *alert = [[MRBAlert alloc] initWithAlertStyle:NSAlertStyleCritical];
//        [alert setMessage:errorTitle infomation:errorMsg];
//        [alert setButtonTitle:@"好" keyEquivalent:@"\r"];
//        [alert runModel];
//
//        [[MRBLogManager defaultManager] showLogWithFormat:@"获取Token信息发生错误：%@，原因：%@", errorTitle, errorMsg];
//    }];
//}

@end
