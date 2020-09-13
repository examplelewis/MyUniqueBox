//
//  MUBLogManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBLogManager.h"

NSString * const MUBLogTimeKey      = @"com.gongyu.MyUniqueBox.MUBLogTimeKey";
NSString * const MUBLogAppendKey    = @"com.gongyu.MyUniqueBox.MUBLogAppendKey";

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

#pragma mark - Log
- (void)clean {
    [self.lock lock];
    self.current = [NSDate date];
    self.newestLog = nil;
//    [self.logs removeAllObjects];
    [self.lock unlock];
    
    dispatch_main_sync_safe(^{
        [MUBUIManager defaultManager].viewController.logTextView.string = @"";
    });
}

- (void)addNewlineLog {
    [self addLogWithType:MUBLogTypeDefault log:@"\n"];
}
- (void)addDefaultLogWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self addLogWithType:MUBLogTypeDefault log:log];
}
- (void)addWarningLogWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self addLogWithType:MUBLogTypeWarning log:log];
}
- (void)addErrorLogWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self addLogWithType:MUBLogTypeError log:log];
}
- (void)addLogWithType:(MUBLogType)type log:(NSString *)log {
    [self addLogWithParams:@{} type:type log:log];
}
- (void)addLogWithParams:(NSDictionary * _Nonnull)params type:(MUBLogType)type log:(NSString *)log {
    BOOL logTime = params[MUBLogTimeKey] ? [params[MUBLogTimeKey] boolValue] : YES;
    BOOL logAppend = params[MUBLogTimeKey] ? [params[MUBLogAppendKey] boolValue] : YES; // 是否接着另起一行
    
    // 日志行的颜色
    NSColor *textColor = [NSColor labelColor];
    if (type == MUBLogTypeWarning) {
        textColor = [NSColor systemYellowColor];
    } else if (type == MUBLogTypeError) {
        textColor = [NSColor systemRedColor];
    }
    
    // 日志
    NSString *logs = @"";
    if (logTime) {
        if (self.current) {
            NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.current];
            logs = [logs stringByAppendingFormat:@"%@ | %@\t\t", [[NSDate date] formattedDateWithFormat:MUBTimeFormatyMdHmsS], [MUBUtilityManager humanReadableTimeFromInterval:interval]];
        } else {
            logs = [logs stringByAppendingFormat:@"%@\t\t", [[NSDate date] formattedDateWithFormat:MUBTimeFormatyMdHmsS]];
        }
    }
    logs = [logs stringByAppendingString:log];
    NSAttributedString *attributedLog = [[NSAttributedString alloc] initWithString:logs attributes:@{NSForegroundColorAttributeName: textColor}];
    
    // 本地日志
    if (type == MUBLogTypeDefault) {
        [self saveDefaultLocalLog:logs];
    } else if (type == MUBLogTypeWarning) {
        [self saveWarningLocalLog:logs];
    } else if (type == MUBLogTypeError) {
        [self saveErrorLocalLog:logs];
    }
    
    // 显示日志
    if (logAppend || !self.newestLog) {
        dispatch_main_sync_safe(^{
            [[MUBUIManager defaultManager].viewController.logTextView.textStorage appendAttributedString:attributedLog];
        });
        
        [self.lock lock];
        self.newestLog = attributedLog;
//        [self.logs addObject:attributedLog];
        [self.lock unlock];
    } else {
        NSRange newestLogRange = [[MUBUIManager defaultManager].viewController.logTextView.textStorage.string rangeOfString:self.newestLog.string];
        dispatch_main_sync_safe(^{
            [[MUBUIManager defaultManager].viewController.logTextView.textStorage replaceCharactersInRange:newestLogRange withAttributedString:attributedLog];
        });
        
        [self.lock lock];
        self.newestLog = attributedLog;
//        [self.logs removeLastObject];
//        [self.logs addObject:attributedLog];
        [self.lock unlock];
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
