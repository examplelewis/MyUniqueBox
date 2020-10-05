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
#import "MUBSQLiteSettingManager.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSMenuItem *buildTimeMenuItem;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    [[MUBSettingManager defaultManager] updatePreferences];
    [[MUBDownloadSettingManager defaultManager] updatePreferences];
    [[MUBDownloadSettingManager defaultManager] updateMenuItems];
    
    [self setupLogger];
    [self setupBuild];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetWeiboToken:) name:MUBDidGetWeiboTokenNotification object:nil];
}
- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleAppleEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES; //点击窗口左上方的关闭按钮退出应用程序
}

#pragma mark - MenuItem Action
- (void)proceedMenuItemPressingWithTag:(NSInteger)tag {
    NSMenuItem *sender = [NSMenuItem new];
    sender.tag = tag;
    [self customMenuItemDidPress:sender];
}
- (IBAction)customMenuItemDidPress:(NSMenuItem *)sender {
    [MUBMenuItemManager customMenuItemDidPress:sender];
}

- (IBAction)helpMenuItemDidPress:(NSMenuItem *)sender {
    
}
- (IBAction)openLogMenuItemDidPress:(NSMenuItem *)sender {
    NSArray *logFilePaths = [MUBFileManager filePathsInFolder:[MUBSettingManager defaultManager].mainFolderPath extensions:@[@"log"]];
    logFilePaths = [logFilePaths sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO]]];
    
    if (![[NSWorkspace sharedWorkspace] openFile:logFilePaths.firstObject]) {
        [MUBAlertManager showCriticalAlertOnMainWindowWithMessage:@"打开日志文件时发生错误，打开失败" info:nil runModal:NO handler:nil];
    }
}
- (IBAction)openPrefsMenuItemDidPress:(NSMenuItem *)sender {
    [MUBFileManager openContentAtPath:[MUBSettingManager defaultManager].preferenceFilePath];
}
- (IBAction)backupDatabasesMenuItemDidPress:(NSMenuItem *)sender {
    [MUBSQLiteSettingManager backupDatabase];
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
- (void)setupBuild {
    NSString *dateStr = [NSString stringWithUTF8String:__DATE__];
    NSString *timeStr = [NSString stringWithUTF8String:__TIME__];
    NSString *str = [NSString stringWithFormat:@"%@ %@", dateStr, timeStr];
    
    NSDate *date = [NSDate dateWithString:str formatString:@"MMM dd yyyy HH:mm:ss"];
    self.buildTimeMenuItem.title = [NSString stringWithFormat:@"最近编译：%@", [date formattedDateWithFormat:@"yyyy/MM/dd HH:mm:ss"]];
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
