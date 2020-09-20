//
//  MUBFileUniversalManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/16.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBFileUniversalManager.h"

@implementation MUBFileUniversalManager

+ (void)showOpenPanelWithType:(MUBFileUniversalType)type {
    MUBOpenPanelBehavior behavior = MUBOpenPanelBehaviorNone;
    NSString *message = @"";
    switch (type) {
        case MUBFileUniversalTypeRename32BitMD5ByFolder:
        case MUBFileUniversalTypeRename32BitMD5ByFile: {
            behavior = MUBOpenPanelBehaviorSingleDir;
            message = @"需要生成名称的文件根目录";
        }
            break;
        case MUBFileUniversalTypeSearchHiddenFile: {
            behavior = MUBOpenPanelBehaviorSingleDir;
            message = @"需要查找隐藏文件的根目录";
        }
            break;
        case MUBFileUniversalTypeRenameSingleFolder:
        case MUBFileUniversalTypeRenameSingleFile:
        case MUBFileUniversalTypeRenameSingleContent: {
            behavior = MUBOpenPanelBehaviorSingleDir;
            message = @"需要重新命名的根目录";
        }
            break;
        default:
            break;
    }
    if (behavior == MUBOpenPanelBehaviorNone) {
        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"MUBFileUniversalManager showOpenPanelWithType behavior == MUBOpenPanelBehaviorNone"];
        return;
    }
    
    [MUBOpenPanelManager showOpenPanelOnMainWindowWithBehavior:behavior message:[NSString stringWithFormat:@"请选择%@", message] handler:^(NSOpenPanel * _Nonnull openPanel, NSModalResponse result) {
        if (result == NSModalResponseOK) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *path = [MUBFileManager pathFromOpenPanelURL:openPanel.URLs.firstObject];
                [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"已选择%@：%@", message, path];
                
                switch (type) {
                    case MUBFileUniversalTypeRename32BitMD5ByFolder:
                    case MUBFileUniversalTypeRename32BitMD5ByFile: {
                        [MUBFileUniversalManager _rename32BitMD5WithRootFolderPath:path byType:type];
                    }
                        break;
                    case MUBFileUniversalTypeSearchHiddenFile: {
                        [MUBFileUniversalManager _searchAndTrashHiddenContentsWithRootFolderPath:path];
                    }
                        break;
                    case MUBFileUniversalTypeRenameSingleFolder:
                    case MUBFileUniversalTypeRenameSingleFile:
                    case MUBFileUniversalTypeRenameSingleContent: {
                        [MUBFileUniversalManager _renameSingleItemWithRootFolderPath:path byType:type];
                    }
                        break;
                    default:
                        break;
                }
            });
        }
    }];
}

#pragma mark - MUBFileUniversalTypeRename32BitMD5
+ (void)_rename32BitMD5WithRootFolderPath:(NSString *)rootFolderPath byType:(MUBFileUniversalType)byType {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"为文件生成32位的随机名称, 流程开始, 选择的根目录: %@", rootFolderPath];
    
    NSArray *filePaths;
    if (byType == MUBFileUniversalTypeRename32BitMD5ByFolder) {
        filePaths = [MUBFileManager allFilePathsInFolder:rootFolderPath];
    } else if (byType == MUBFileUniversalTypeRename32BitMD5ByFile) {
        filePaths = [MUBFileManager filePathsInFolder:rootFolderPath];
    }
    if (filePaths.count == 0) {
        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"为文件生成32位的随机名称, 流程失败: 选择的文件夹中没有文件"];
    }
    
    for (NSInteger i = 0; i < filePaths.count; i++) {
        NSString *filePath = filePaths[i];
        NSString *folderPath = filePath.stringByDeletingLastPathComponent;
        
        NSString *folderMD5 = [self _md5MiddleStringFromPath:folderPath];
        NSString *fileMD5 = [self _md5MiddleStringFromPath:filePath];
        NSString *newFilePath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.%@", folderMD5, fileMD5, filePath.pathExtension]];
        
        [MUBFileManager moveItemFromPath:filePath toPath:newFilePath];
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"\n重命名前：\t%@/%@\n重命名后：\t%@/%@", filePath.stringByDeletingLastPathComponent.lastPathComponent, filePath.lastPathComponent, newFilePath.stringByDeletingLastPathComponent.lastPathComponent, newFilePath.lastPathComponent];
    }
    
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"为文件生成32位的随机名称, 流程结束"];
}
+ (NSString *)_md5MiddleStringFromPath:(NSString *)path {
    NSDate *creationDate = [MUBFileManager attribute:NSFileCreationDate ofItemAtPath:path];
    NSString *desc = [NSString stringWithFormat:@"%@%@", path.lastPathComponent, creationDate];
    return desc.md5String.md5Middle;
}

#pragma mark - MUBFileUniversalTypeSearchHiddenFile
+ (void)_searchAndTrashHiddenContentsWithRootFolderPath:(NSString *)rootFolderPath {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"将文件夹中的文件(夹)移动到废纸篓, 流程开始, 选择的根目录: %@", rootFolderPath];
    
    NSArray<NSString *> *trashPaths = [[MUBFileManager allContentPathsInFolder:rootFolderPath] bk_select:^BOOL(NSString *contentPath) {
        return [contentPath.lastPathComponent hasPrefix:@"."];
    }];
    if (trashPaths.count == 0) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"未找到隐藏文件"];
    } else {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"已找到 %ld 个隐藏文件, 即将移动至废纸篓", trashPaths.count];
        [MUBFileManager trashFilePaths:trashPaths];
    }
    
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"将文件夹中的文件(夹)移动到废纸篓, 流程结束"];
}

#pragma mark - MUBFileUniversalTypeRenameSingleItem
+ (void)_renameSingleItemWithRootFolderPath:(NSString *)rootFolderPath byType:(MUBFileUniversalType)byType {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"将只有一个子项目命名为父文件夹的名称, 流程开始, 选择的根目录: %@", rootFolderPath];
    
    NSArray *folderPaths = [MUBFileManager folderPathsInFolder:rootFolderPath];
    for (NSInteger i = 0; i < folderPaths.count; i++) {
        NSString *folderPath = folderPaths[i];
        NSArray *allFolderPaths = [MUBFileManager allFolderPathsInFolder:folderPath];
        NSArray *allFilePaths = [MUBFileManager allFilePathsInFolder:folderPath];
        NSArray *allContentPaths = [MUBFileManager allContentPathsInFolder:folderPath];
        
        NSString *itemPath = @"";
        if (byType == MUBFileUniversalTypeRenameSingleFolder && allFolderPaths.count == 1) {
            itemPath = allFolderPaths.firstObject;
        }
        if (byType == MUBFileUniversalTypeRenameSingleFile && allFilePaths.count == 1) {
            itemPath = allFilePaths.firstObject;
        }
        if (byType == MUBFileUniversalTypeRenameSingleContent && allContentPaths.count == 1) {
            itemPath = allContentPaths.firstObject;
        }
        if (itemPath.length == 0) {
            continue;
        }
        
        NSString *folderName = folderPath.lastPathComponent;
        NSString *destItemPath = @"";
        if ([MUBFileManager contentIsFolderAtPath:itemPath]) {
            destItemPath = [itemPath.stringByDeletingLastPathComponent stringByAppendingPathComponent:folderName];
        } else if ([folderName.pathExtension isEqualToString:itemPath.pathExtension]) {
            destItemPath = [itemPath.stringByDeletingLastPathComponent stringByAppendingPathComponent:folderName];
        } else {
            destItemPath = [itemPath.stringByDeletingLastPathComponent stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", folderName, itemPath.pathExtension]];
        }
        if (destItemPath.length == 0) {
            continue;
        }
        
        [MUBFileManager moveItemFromPath:itemPath toPath:destItemPath];
        
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"将: %@", itemPath];
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"重命名为: %@", destItemPath];
    }
    
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"将只有一个子项目命名为父文件夹的名称, 流程结束"];
}

@end
