//
//  NSArray+MUBAdd.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "NSArray+MUBAdd.h"

@implementation NSArray (MUBAdd)

- (BOOL)isNotEmpty {
    return [self isKindOfClass:[NSArray class]] && self.count > 0;
}

- (NSString *)stringValue {
    if (!self.isNotEmpty) {
        return nil;
    }
    
    //转换成NSString
    NSString *tempStr1 = [self.description stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSString *str = [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListImmutable format:NULL error:&error];
    if (error) {
        [[MUBLogManager defaultManager] addDefaultLogWithBehavior:MUBLogBehaviorOnBothTimeAppend format:@"将 NSArray 转换成 NSString 的时候出错: %@", error.localizedDescription];
        
        return nil;
    }
    
    //删除NSString中没有用的符号
    str = [str stringByReplacingOccurrencesOfString:@"(\n" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\n)" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"    " withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"," withString:@""];
    
    return str;
}

#pragma mark - Export
- (void)exportToPath:(NSString *)path {
    [self exportToPath:path behavior:MUBFileOpertaionBehaviorNone];
}
- (void)exportToPath:(NSString *)path behavior:(MUBFileOpertaionBehavior)behavior {
    BOOL exportNoneContent = behavior & MUBFileOpertaionBehaviorExportNoneContent;
    BOOL showSuccessLog = behavior & MUBFileOpertaionBehaviorShowSuccessLog;
    
    if (!self.isNotEmpty) {
        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"输出到: %@ 的内容为空%@", path, !exportNoneContent ? @"，已忽略" : @""];
        if (!exportNoneContent) {
            return;
        }
    }
    
    NSString *content = self.stringValue;
    if (!content) {
        // 说明转换的时候出了错误，换一种直接的方式
        content = [self componentsJoinedByString:@"\n"];
    }
    
    NSError *error;
    if ([content writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
        if (showSuccessLog) {
            [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"结果文件导出成功，请查看：%@", path];
        }
    } else {
        [[MUBLogManager defaultManager] addErrorLogWithFormat:@"导出结果文件出错：%@", error.localizedDescription];
    }
}
- (void)exportToPlistPath:(NSString *)plistPath {
    [self exportToPlistPath:plistPath behavior:MUBFileOpertaionBehaviorNone];
}
- (void)exportToPlistPath:(NSString *)plistPath behavior:(MUBFileOpertaionBehavior)behavior {
    BOOL exportNoneContent = behavior & MUBFileOpertaionBehaviorExportNoneContent;
    BOOL showSuccessLog = behavior & MUBFileOpertaionBehaviorShowSuccessLog;
    
    if (!self.isNotEmpty) {
        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"输出到: %@ 的内容为空%@", plistPath, !exportNoneContent ? @"，已忽略" : @""];
        if (!exportNoneContent) {
            return;
        }
    }
    
    NSError *error;
    if ([self.plistData writeToFile:plistPath atomically:YES]) {
        if (showSuccessLog) {
            [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"结果文件导出成功，请查看：%@", plistPath];
        }
    } else {
        [[MUBLogManager defaultManager] addErrorLogWithFormat:@"导出结果文件出错：%@", error.localizedDescription];
    }
}

@end
