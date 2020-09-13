//
//  NSString+MUBAdd.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "NSString+MUBAdd.h"

@implementation NSString (MUBAdd)

- (BOOL)isEmpty {
    return !self.isNotEmpty;
}
- (BOOL)isNotEmpty {
    return self && [self isKindOfClass:[NSString class]] && self.length > 0;
}

- (void)exportToPath:(NSString *)path {
    if (self.isEmpty) {
        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"输出到: %@ 的内容为空，已忽略", path];
        return;
    }
    
    NSError *error;
    if ([self writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"结果文件导出成功，请查看：%@", path];
    } else {
        [[MUBLogManager defaultManager] addErrorLogWithFormat:@"导出结果文件出错：%@", error.localizedDescription];
    }
}

@end
