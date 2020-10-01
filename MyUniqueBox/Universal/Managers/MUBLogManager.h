//
//  MUBLogManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, MUBLogBehavior) {
    MUBLogBehaviorNone              = 0,
    MUBLogBehaviorLevelDefault      = 1 << 0,
    MUBLogBehaviorLevelWarning      = 1 << 1,
    MUBLogBehaviorLevelError        = 1 << 2,
    MUBLogBehaviorOnView            = 1 << 5,   // 在页面上显示Log
    MUBLogBehaviorOnDDLog           = 1 << 6,   // 使用CocoaLumberJack处理Log
    MUBLogBehaviorOnBoth            = MUBLogBehaviorOnView | MUBLogBehaviorOnDDLog, // 在页面上显示Log, 使用CocoaLumberJack处理Log
    MUBLogBehaviorTime              = 1 << 9,   // 显示时间
    MUBLogBehaviorAppend            = 1 << 10,  // 新日志以添加的形式
    
    MUBLogBehaviorOnBothTimeAppend    = MUBLogBehaviorOnBoth | MUBLogBehaviorTime | MUBLogBehaviorAppend,
    MUBLogBehaviorOnViewTimeAppend    = MUBLogBehaviorOnView | MUBLogBehaviorTime | MUBLogBehaviorAppend,
    MUBLogBehaviorOnDDLogTimeAppend   = MUBLogBehaviorOnDDLog | MUBLogBehaviorTime | MUBLogBehaviorAppend,
    
    MUBLogBehaviorOnBothAppend        = MUBLogBehaviorOnBoth | MUBLogBehaviorAppend,
    MUBLogBehaviorOnViewAppend        = MUBLogBehaviorOnView | MUBLogBehaviorAppend,
    MUBLogBehaviorOnDDLogAppend       = MUBLogBehaviorOnDDLog | MUBLogBehaviorAppend,
    
    MUBLogBehaviorOnBothTime          = MUBLogBehaviorOnBoth | MUBLogBehaviorTime,
    MUBLogBehaviorOnViewTime          = MUBLogBehaviorOnView | MUBLogBehaviorTime,
    MUBLogBehaviorOnDDLogTime         = MUBLogBehaviorOnDDLog | MUBLogBehaviorTime,
};

@interface MUBLogManager : NSObject

#pragma mark - Lifecycle
+ (instancetype)defaultManager;

#pragma mark - Log Clean / Reset
- (void)clean;
- (void)reset;

#pragma mark - Log 换行
- (void)addNewlineLog;

#pragma mark - Log 页面和文件，显示时间，添加新的日志
- (void)addDefaultLogWithFormat:(NSString *)format, ...;
- (void)addWarningLogWithFormat:(NSString *)format, ...;
- (void)addErrorLogWithFormat:(NSString *)format, ...;

#pragma mark - Log 页面和文件，显示时间，新的日志覆盖之前的日志
- (void)addReplaceDefaultLogWithFormat:(NSString *)format, ...;
- (void)addReplaceWarningLogWithFormat:(NSString *)format, ...;
- (void)addReplaceErrorLogWithFormat:(NSString *)format, ...;

#pragma mark - Log 自定义
- (void)addDefaultLogWithBehavior:(MUBLogBehavior)behavior format:(NSString *)format, ...;
- (void)addWarningLogWithBehavior:(MUBLogBehavior)behavior format:(NSString *)format, ...;
- (void)addErrorLogWithBehavior:(MUBLogBehavior)behavior format:(NSString *)format, ...;

#pragma mark - Local Log
- (void)saveDefaultLocalLog:(NSString *)log;
- (void)saveWarningLocalLog:(NSString *)log;
- (void)saveErrorLocalLog:(NSString *)log;

@end

NS_ASSUME_NONNULL_END
