//
//  MUBLogManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const MUBLogTimeKey;
extern NSString * const MUBLogAppendKey;

typedef NS_ENUM(NSUInteger, MUBLogType) {
    MUBLogTypeDefault,
    MUBLogTypeWarning,
    MUBLogTypeError
};

@interface MUBLogManager : NSObject

+ (instancetype)defaultManager;

- (void)clean;

- (void)addNewlineLog;
- (void)addDefaultLogWithFormat:(NSString *)format, ...;
- (void)addWarningLogWithFormat:(NSString *)format, ...;
- (void)addErrorLogWithFormat:(NSString *)format, ...;
- (void)addLogWithParams:(NSDictionary * _Nonnull)params type:(MUBLogType)type log:(NSString *)log;

@end

NS_ASSUME_NONNULL_END
