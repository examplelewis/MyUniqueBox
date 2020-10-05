//
//  MUBLogManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBLogManager.h"

@interface MUBLogManager ()

//@property (strong) NSMutableArray *logs; // 日志
@property (strong) NSAttributedString *newestLog;
@property (strong) NSDate *current;
@property (strong) NSLock *lock;

@end

@implementation MUBLogManager

#pragma mark - Lifecycle
+ (instancetype)defaultManager {
    static MUBLogManager *defaultManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [[self alloc] init];
    });
    
    return defaultManager;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.lock = [NSLock new];
//        self.logs = [NSMutableArray array];
    }
    
    return self;
}

#pragma mark - Log Clean / Reset
- (void)clean {
    [self.lock lock];
    self.newestLog = nil;
//    [self.logs removeAllObjects];
    [self.lock unlock];
    
    dispatch_main_async_safe((^{
        [MUBUIManager defaultManager].viewController.logTextView.string = @"";
    }));
}
- (void)reset {
    [self.lock lock];
    self.current = [NSDate date];
    self.newestLog = nil;
//    [self.logs removeAllObjects];
    [self.lock unlock];
    
    dispatch_main_async_safe((^{
        [MUBUIManager defaultManager].viewController.logTextView.string = @"";
    }));
}

#pragma mark - Log 换行
- (void)addNewlineLog {
    [self _addLogWithBehavior:MUBLogBehaviorLevelDefault | MUBLogBehaviorOnBothTimeAppend log:@""];
}

#pragma mark - Log 页面和文件，显示时间，添加新的日志
- (void)addDefaultLogWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self _addLogWithBehavior:MUBLogBehaviorLevelDefault | MUBLogBehaviorOnBothTimeAppend log:log];
}
- (void)addWarningLogWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self _addLogWithBehavior:MUBLogBehaviorLevelWarning | MUBLogBehaviorOnBothTimeAppend log:log];
}
- (void)addErrorLogWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self _addLogWithBehavior:MUBLogBehaviorLevelError | MUBLogBehaviorOnBothTimeAppend log:log];
}

#pragma mark - Log 页面和文件，显示时间，新的日志覆盖之前的日志
- (void)addReplaceDefaultLogWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self _addLogWithBehavior:MUBLogBehaviorLevelDefault | MUBLogBehaviorOnBothTime log:log];
}
- (void)addReplaceWarningLogWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self _addLogWithBehavior:MUBLogBehaviorLevelWarning | MUBLogBehaviorOnBothTime log:log];
}
- (void)addReplaceErrorLogWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self _addLogWithBehavior:MUBLogBehaviorLevelError | MUBLogBehaviorOnBothTime log:log];
}

#pragma mark - Log 自定义
- (void)addDefaultLogWithBehavior:(MUBLogBehavior)behavior format:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self _addLogWithBehavior:MUBLogBehaviorLevelDefault | behavior log:log];
}
- (void)addWarningLogWithBehavior:(MUBLogBehavior)behavior format:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self _addLogWithBehavior:MUBLogBehaviorLevelWarning | behavior log:log];
}
- (void)addErrorLogWithBehavior:(MUBLogBehavior)behavior format:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self _addLogWithBehavior:MUBLogBehaviorLevelError | behavior log:log];
}

#pragma mark - Log 内部实现
- (void)_addLogWithBehavior:(MUBLogBehavior)behavior log:(NSString *)log {
    if (behavior & MUBLogBehaviorNone) {
        return;
    }
    
    // 日志内容
    NSString *logs = @"";
    if (behavior & MUBLogBehaviorTime) {
        if (self.current) {
            NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.current];
            logs = [logs stringByAppendingFormat:@"%@ | %@\t\t", [[NSDate date] stringWithFormat:MUBTimeFormatyMdHmsS], [MUBUtilityManager humanReadableTimeFromInterval:interval]];
        } else {
            logs = [logs stringByAppendingFormat:@"%@\t\t", [[NSDate date] stringWithFormat:MUBTimeFormatyMdHmsS]];
        }
    }
    logs = [logs stringByAppendingString:log];
    
    // 本地日志
    if (behavior & MUBLogBehaviorOnDDLog) {
        // 本地文件不记录时间，因为CocoaLumberJack会自动添加时间
        if (behavior & MUBLogBehaviorLevelDefault) {
            [self saveDefaultLocalLog:log];
        } else if (behavior & MUBLogBehaviorLevelWarning) {
            [self saveWarningLocalLog:log];
        } else if (behavior & MUBLogBehaviorLevelError) {
            [self saveErrorLocalLog:log];
        }
    }
    
    // 输出日志
    if (behavior & MUBLogBehaviorOnView) {
        // 添加日志的样式
        NSColor *textColor = [NSColor labelColor];
        if (behavior & MUBLogBehaviorLevelWarning) {
            textColor = [NSColor systemYellowColor];
        } else if (behavior & MUBLogBehaviorLevelError) {
            textColor = [NSColor systemRedColor];
        }
        NSAttributedString *attributedLog = [[NSAttributedString alloc] initWithString:logs attributes:@{NSForegroundColorAttributeName: textColor}];
        
        // 显示日志
        dispatch_main_async_safe((^{
            if ((behavior & MUBLogBehaviorAppend) || !self.newestLog) {
                // 如果不是第一行的话，那么添加一个空行
                if ([MUBUIManager defaultManager].viewController.logTextView.textStorage.length != 0) {
                    NSAttributedString *newLineLog = [[NSAttributedString alloc] initWithString:@"\n" attributes:@{NSForegroundColorAttributeName: textColor}];
                    [[MUBUIManager defaultManager].viewController.logTextView.textStorage appendAttributedString:newLineLog];
                }
                [[MUBUIManager defaultManager].viewController.logTextView.textStorage appendAttributedString:attributedLog];
            } else {
                NSRange newestLogRange = [[MUBUIManager defaultManager].viewController.logTextView.textStorage.string rangeOfString:self.newestLog.string];
                [[MUBUIManager defaultManager].viewController.logTextView.textStorage replaceCharactersInRange:newestLogRange withAttributedString:attributedLog];
            }
            [[MUBUIManager defaultManager] scrollNewestLogVisible];
            
            [self.lock lock];
            self.newestLog = attributedLog;
            if (!(behavior & MUBLogBehaviorAppend) && self.newestLog) {
//                [self.logs removeLastObject];
            }
//            [self.logs addObject:attributedLog];
            [self.lock unlock];
        }));
    }
}

#pragma mark - Local Log
- (void)saveDefaultLocalLog:(NSString *)log {
    DDLogInfo(@"%@", log);
}
- (void)saveWarningLocalLog:(NSString *)log {
    DDLogWarn(@"%@", log);
}
- (void)saveErrorLocalLog:(NSString *)log {
    DDLogError(@"%@", log);
}

@end
