//
//  MUBSQLiteSettingManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/29.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBSQLiteSettingManager.h"

#import "MUBSQLiteHeader.h"

@implementation MUBSQLiteSettingManager

// 备份数据库文件
+ (void)backupDatabase {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"备份数据库文件, 流程开始"];
    
    NSString *sqliteName = MUBSQLiteFileName.stringByDeletingPathExtension;
    NSString *sqliteFilePath = [[MUBSettingManager defaultManager] pathOfContentInMainFolder:MUBSQLiteFileName];
    if (![MUBFileManager fileExistsAtPath:sqliteFilePath]) {
        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"%@ 文件不存在", sqliteFilePath];
        return;
    }
    
    // 删除过往的备份文件
    NSArray *sqliteFilePaths = [MUBFileManager filePathsInFolder:[MUBSettingManager defaultManager].mainFolderPath extensions:@[@"sqlite"]];
    for (NSString *filePath in sqliteFilePaths) {
        if ([filePath.lastPathComponent hasPrefix:[NSString stringWithFormat:@"%@_", sqliteName]]) {
            NSError *error;
            BOOL success = [MUBFileManager trashItemAtURL:[NSURL fileURLWithPath:filePath] resultingItemURL:nil error:&error];
            if (success) {
                [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"旧备份文件: %@, 删除成功", filePath];
            } else {
                [[MUBLogManager defaultManager] addErrorLogWithFormat:@"旧备份文件: %@, 删除失败: %@", filePath, [error localizedDescription]];
            }
        }
    }
    
    // 复制数据库文件
    NSString *dateString = [[NSDate date] formattedDateWithFormat:MUBTimeFormatCompactyMd];
    NSString *destFilePath = [[MUBSettingManager defaultManager] pathOfContentInMainFolder:[NSString stringWithFormat:@"%@_%@.sqlite", sqliteName, dateString]];
    
    NSError *error;
    BOOL success = [MUBFileManager copyItemFromPath:sqliteFilePath toPath:destFilePath error:&error];
    if (success) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"数据库文件: %@, 备份成功", sqliteFilePath];
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"备份文件: %@", destFilePath];
    } else {
        [[MUBLogManager defaultManager] addErrorLogWithFormat:@"备份文件: %@,  备份失败: %@", destFilePath, [error localizedDescription]];
    }
    
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"备份数据库文件, 流程结束"];
}
// 还原数据库文件
+ (void)restoreDatebase {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"还原数据库文件, 流程开始"];
    
    // 先查找备份数据库文件是否存在
    NSArray *sqliteFilePaths = [MUBFileManager filePathsInFolder:[MUBSettingManager defaultManager].mainFolderPath extensions:@[@"sqlite"]];
    sqliteFilePaths = [sqliteFilePaths bk_select:^BOOL(NSString *obj) {
        return [obj.lastPathComponent caseInsensitiveCompare:@"data.sqlite"] != NSOrderedSame;
    }];
    sqliteFilePaths = [sqliteFilePaths sortedArrayUsingComparator:^NSComparisonResult(NSString * _Nonnull obj1, NSString * _Nonnull obj2) {
        return [obj1 caseInsensitiveCompare:obj2] == NSOrderedAscending;
    }];
    if (sqliteFilePaths.count == 0) {
        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"没有数据库备份文件"];
        return;
    }
    
    // 再查找原数据库文件是否存在，存在的话就删除
    NSString *sqliteFilePath = [[MUBSettingManager defaultManager] pathOfContentInMainFolder:MUBSQLiteFileName];
    if ([MUBFileManager fileExistsAtPath:sqliteFilePath]) {
        NSError *error;
        BOOL success = [MUBFileManager trashItemAtURL:[NSURL fileURLWithPath:sqliteFilePath] resultingItemURL:nil error:&error];
        if (success) {
            [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"数据库文件: %@, 删除成功", sqliteFilePath];
        } else {
            [[MUBLogManager defaultManager] addErrorLogWithFormat:@"数据库文件: %@, 删除失败: %@", sqliteFilePath, [error localizedDescription]];
            
            [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"还原数据库文件, 流程结束"];
            return;
        }
    }
    
    // 还原备份数据库文件
    NSString *backupSqliteFilePath = sqliteFilePaths.firstObject;
    NSError *error;
    BOOL success = [MUBFileManager copyItemFromPath:backupSqliteFilePath toPath:sqliteFilePath error:&error];
    if (success) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"数据库文件: %@, 还原成功", backupSqliteFilePath];
    } else {
        [[MUBLogManager defaultManager] addErrorLogWithFormat:@"数据库文件: %@, 还原失败: %@", backupSqliteFilePath, [error localizedDescription]];
    }
    
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"还原数据库文件, 流程结束"];
}
// 去除数据库中重复的内容
+ (void)removeDuplicates {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"去除数据库中重复的内容：已经准备就绪"];
    
//    [[MRBSQLiteFMDBManager defaultDBManager] removeDuplicateLinksFromDatabase];
//    [[MRBSQLiteFMDBManager defaultDBManager] removeDuplicateImagesFromDatabase];
    
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"去除数据库中重复的内容：流程已经结束"];
    
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"即将开始备份数据库"];
    [MUBSQLiteSettingManager backupDatabase];
}

@end
