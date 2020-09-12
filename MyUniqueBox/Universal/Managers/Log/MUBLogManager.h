//
//  MUBLogManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * _Nonnull const MUBLogTimeKey;
extern NSString * _Nonnull const MUBLogAppendKey;

typedef NS_ENUM(NSUInteger, MUBLogType) {
    MUBLogTypeDefault,
    MUBLogTypeWarning,
    MUBLogTypeError
};

NS_ASSUME_NONNULL_BEGIN

@interface MUBLogManager : NSObject

+ (instancetype)sharedManager;

- (void)addNewlineLog;
- (void)addDefaultLogWithFormat:(NSString *)format, ...;
- (void)addWarningLogWithFormat:(NSString *)format, ...;
- (void)addErrorLogWithFormat:(NSString *)format, ...;
- (void)addLogWithParams:(NSDictionary * _Nonnull)params type:(MUBLogType)type format:(NSString *)format, ...;

@end

NS_ASSUME_NONNULL_END
