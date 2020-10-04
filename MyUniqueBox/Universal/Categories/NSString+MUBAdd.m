//
//  NSString+MUBAdd.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "NSString+MUBAdd.h"

@implementation NSString (MUBAdd)

- (BOOL)isNotEmpty {
    return [self isKindOfClass:[NSString class]] && self.length > 0;
}

- (NSString *)md5Middle {
    if (self.length != 32) { // MD5都是32位的
        return self;
    } else {
        return [self substringWithRange:NSMakeRange(self.length / 4, self.length / 2)];
    }
}

#pragma mark - Export
- (void)exportToPath:(NSString *)path {
    [self exportToPath:path behavior:MUBFileOpertaionBehaviorNone];
}
- (void)exportToPath:(NSString *)path behavior:(MUBFileOpertaionBehavior)behavior {
    BOOL showNoneLog = behavior & MUBFileOpertaionBehaviorShowNoneLog;
    BOOL showSuccessLog = behavior & MUBFileOpertaionBehaviorShowSuccessLog;
    BOOL exportNoneLog = behavior & MUBFileOpertaionBehaviorExportNoneLog;
    
    if (!self.isNotEmpty) {
        if (showNoneLog) {
            [[MUBLogManager defaultManager] addWarningLogWithFormat:@"输出到: %@ 的内容为空%@，已忽略", path];
        }
        if (!exportNoneLog) {
            return;
        }
    }
    
    NSError *error;
    if ([self writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
        if (showSuccessLog) {
            [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"结果文件导出成功，请查看：%@", path];
        }
    } else {
        [[MUBLogManager defaultManager] addErrorLogWithFormat:@"导出结果文件出错：%@", error.localizedDescription];
    }
}

@end
