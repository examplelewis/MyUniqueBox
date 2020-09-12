//
//  AppDelegate.m
//  MyUniqueBox
//
//  Created by 龚宇 on 2020/9/11.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
}
- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark - Setup
- (void)setupLogger {
    //在系统上保持一周的日志文件
    DDLogFileManagerDefault *logFileManager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:MUBMainFolderPath];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:logFileManager];
    fileLogger.rollingFrequency = 60 * 60 * 24 * 7; // 7 days rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 3;
    fileLogger.maximumFileSize = 10 * 1024 * 1024;
    
    [DDLog addLogger:fileLogger];
    
#pragma mark RELEASE 的时候不需要添加 console 日志，只保留文件日志
#ifdef DEBUG
    NSLog(@"logDirectory: %@", logDirectory);
    
    DDTTYLogger *ttyLogger = [DDTTYLogger sharedInstance];
    [DDLog addLogger:ttyLogger]; // console 日志
#endif
}


@end
