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
+ (instancetype)sharedManager {
    static MUBLogManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
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
    self.current = nil;
//    [self.logs removeAllObjects];
    [self.lock unlock];
    
    dispatch_main_sync_safe(^{
        [MUBUIManager sharedManager].viewController.logTextView.string = @"";
    });
}

- (void)addNewlineLog {
    [self addLogWithType:MUBLogTypeDefault format:@"\n"];
}
- (void)addDefaultLogWithFormat:(NSString *)format, ... {
    [self addLogWithType:MUBLogTypeDefault format:format];
}
- (void)addWarningLogWithFormat:(NSString *)format, ... {
    [self addLogWithType:MUBLogTypeWarning format:format];
}
- (void)addErrorLogWithFormat:(NSString *)format, ... {
    [self addLogWithType:MUBLogTypeError format:format];
}
- (void)addLogWithType:(MUBLogType)type format:(NSString *)format, ... {
    [self addLogWithParams:@{} type:type format:format];
}
- (void)addLogWithParams:(NSDictionary * _Nonnull)params type:(MUBLogType)type format:(NSString *)format, ... {
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
    NSString *log = @"";
    if (logTime) {
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.current];
        log = [log stringByAppendingFormat:@"%@ | %@\t\t", [[NSDate date] formattedDateWithFormat:MUBTimeFormatyMdHmsS], [MUBUtilityManager humanReadableTimeFromInterval:interval]];
    }
    log = [log stringByAppendingFormat:@"%@", [self logFromFormat:format]];
    NSAttributedString *attributedLog = [[NSAttributedString alloc] initWithString:log attributes:@{NSForegroundColorAttributeName: textColor}];
    
    // 显示日志
    [self.lock lock];
    if (logAppend) {
        dispatch_main_sync_safe(^{
            [[MUBUIManager sharedManager].viewController.logTextView.textStorage appendAttributedString:attributedLog];
        });
        
        self.newestLog = attributedLog;
//        [self.logs addObject:attributedLog];
    } else {
        NSRange newestLogRange = [[MUBUIManager sharedManager].viewController.logTextView.textStorage.string rangeOfString:self.newestLog.string];
        dispatch_main_sync_safe(^{
            [[MUBUIManager sharedManager].viewController.logTextView.textStorage replaceCharactersInRange:newestLogRange withAttributedString:attributedLog];
        });
        
        self.newestLog = attributedLog;
//        [self.logs removeLastObject];
//        [self.logs addObject:attributedLog];
    }
    
    
    [self.lock unlock];
}



#pragma mark - Tool
- (NSString *)logFromFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    return log;
}



@end
