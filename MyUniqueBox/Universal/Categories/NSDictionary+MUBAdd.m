//
//  NSDictionary+MUBAdd.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "NSDictionary+MUBAdd.h"

@implementation NSDictionary (MUBAdd)

- (BOOL)isEmpty {
    return !self.isNotEmpty;
}
- (BOOL)isNotEmpty {
    return self && [self isKindOfClass:[NSDictionary class]] && self.count > 0;
}

- (NSString *)stringValue {
    if (self.isEmpty) {
        return nil;
    }
    
    //转换成NSString
    NSString *tempStr1 = [self.description stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSString *str = [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListImmutable format:NULL error:NULL];
    if (error) {
        [[MUBLogManager defaultManager] addDefaultLogWithBehavior:MUBLogBehaviorOnBothTimeAppend format:@"将 NSDictionary 转换成 NSString 的时候出错: %@", error.localizedDescription];
        
        return nil;
    }
    
    //删除NSString中没有用的符号
    str = [str stringByReplacingOccurrencesOfString:@"    " withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    str = [str stringByReplacingOccurrencesOfString:@"{\n" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"(\n" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\n)" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\n}" withString:@""];
    
    return str;
}

- (void)exportToPath:(NSString *)path {
    if (self.isEmpty) {
        [[MUBLogManager defaultManager] addWarningLogWithBehavior:MUBLogBehaviorOnBothTimeAppend format:@"输出到: %@ 的内容为空，已忽略", path];
        return;
    }
    
    NSError *error;
    if ([self.stringValue writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"结果文件导出成功，请查看：%@", path];
    } else {
        [[MUBLogManager defaultManager] addErrorLogWithFormat:@"导出结果文件出错：%@", error.localizedDescription];
    }
}
- (void)exportToPlistPath:(NSString *)plistPath {
    if (self.isEmpty) {
        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"输出到: %@ 的内容为空，已忽略", plistPath];
        return;
    }
    
    NSError *error;
    if ([self.plistData writeToFile:plistPath atomically:YES]) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"结果文件导出成功，请查看：%@", plistPath];
    } else {
        [[MUBLogManager defaultManager] addErrorLogWithFormat:@"导出结果文件出错：%@", error.localizedDescription];
    }
}

@end
