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
        case MUBFileUniversalTypeRenameAsSuperFodlerNameOnSingleFolder:
        case MUBFileUniversalTypeRenameAsSuperFodlerNameOnSingleFile:
        case MUBFileUniversalTypeRenameAsSuperFodlerNameOnSingleContent: {
            behavior = MUBOpenPanelBehaviorSingleDir;
            message = @"需要重新命名的根目录";
        }
            break;
        case MUBFileUniversalTypeRenameAddSuperFolderNameOnAllFolders: {
            behavior = MUBOpenPanelBehaviorMultipleDir;
            message = @"需要将所有子文件夹前加上父文件夹名称【可多选】的根目录";
        }
            break;
        case MUBFileUniversalTypeCopyFolderHierarchy: {
            behavior = MUBOpenPanelBehaviorSingleDir;
            message = @"需要需要复制层级的根目录";
        }
        default:
            break;
    }
    if (behavior == MUBOpenPanelBehaviorNone) {
        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"MUBFileUniversalManager showOpenPanelWithType behavior == MUBOpenPanelBehaviorNone"];
        return;
    }
    
    [MUBFileUniversalManager _showOpenPanelWithType:type behavior:behavior message:message];
}
+ (void)_showOpenPanelWithType:(MUBFileUniversalType)type behavior:(MUBOpenPanelBehavior)behavior message:(NSString *)message {
    [MUBOpenPanelManager showOpenPanelOnMainWindowWithBehavior:behavior message:[NSString stringWithFormat:@"请选择%@", message] handler:^(NSOpenPanel * _Nonnull openPanel, NSModalResponse result) {
        if (result == NSModalResponseOK) {
            if (behavior & MUBOpenPanelBehaviorMultiple) {
                dispatch_async(dispatch_get_main_queue(), ^{
                switch (type) {
                    case MUBFileUniversalTypeRenameAddSuperFolderNameOnAllFolders: {
                        for (NSInteger i = 0; i < openPanel.URLs.count; i++) {
                            NSString *folderPath = [MUBFileManager pathFromOpenPanelURL:openPanel.URLs[i]];
                            [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"已选择%@：%@", message, folderPath];
                            
                            [MUBFileUniversalManager _renameSingleContentAddSuperFolderNameWithSuperFolderPath:folderPath byType:type];
                        }
                    }
                        break;
                    default:
                        break;
                }
                    
                });
            } else {
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
                        case MUBFileUniversalTypeRenameAsSuperFodlerNameOnSingleFolder:
                        case MUBFileUniversalTypeRenameAsSuperFodlerNameOnSingleFile:
                        case MUBFileUniversalTypeRenameAsSuperFodlerNameOnSingleContent: {
                            [MUBFileUniversalManager _renameSingleItemAsSuperFodlerNameWithRootFolderPath:path byType:type];
                        }
                            break;
                        case MUBFileUniversalTypeCopyFolderHierarchy: {
                            [MUBFileUniversalManager _copyFolderHierarchyWithRootFolderPath:path];
                        }
                            break;
                        default:
                            break;
                    }
                });
            }
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

#pragma mark - MUBFileUniversalTypeRenameAsSuperFodlerName
+ (void)_renameSingleItemAsSuperFodlerNameWithRootFolderPath:(NSString *)rootFolderPath byType:(MUBFileUniversalType)byType {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"将只有一个子项目命名为父文件夹的名称, 流程开始, 选择的根目录: %@", rootFolderPath];
    
    NSArray *folderPaths = [MUBFileManager folderPathsInFolder:rootFolderPath];
    for (NSInteger i = 0; i < folderPaths.count; i++) {
        NSString *folderPath = folderPaths[i];
        NSArray *folderPaths = [MUBFileManager folderPathsInFolder:folderPath];
        NSArray *filePaths = [MUBFileManager filePathsInFolder:folderPath];
        NSArray *contentPaths = [MUBFileManager contentPathsInFolder:folderPath];
        
        NSString *itemPath = @"";
        if (byType == MUBFileUniversalTypeRenameAsSuperFodlerNameOnSingleFolder && folderPaths.count == 1) {
            itemPath = folderPaths.firstObject;
        }
        if (byType == MUBFileUniversalTypeRenameAsSuperFodlerNameOnSingleFile && filePaths.count == 1) {
            itemPath = filePaths.firstObject;
        }
        if (byType == MUBFileUniversalTypeRenameAsSuperFodlerNameOnSingleContent && contentPaths.count == 1) {
            itemPath = contentPaths.firstObject;
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

#pragma mark - MUBFileUniversalTypeRenameAddSuperFolderName
+ (void)_renameSingleContentAddSuperFolderNameWithSuperFolderPath:(NSString *)superFolderPath byType:(MUBFileUniversalType)byType {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"将所有子文件夹的名称前加上根文件夹的名称, 流程开始, 选择的根目录: %@", superFolderPath];
    
    NSArray *itemPaths = @[];
    if (byType == MUBFileUniversalTypeRenameAddSuperFolderNameOnAllFolders) {
        itemPaths = [MUBFileManager folderPathsInFolder:superFolderPath];
    }
    if (byType == MUBFileUniversalTypeRenameAddSuperFolderNameOnAllFiles) {
        itemPaths = [MUBFileManager filePathsInFolder:superFolderPath];
    }
    if (byType == MUBFileUniversalTypeRenameAddSuperFolderNameOnAllContents) {
        itemPaths = [MUBFileManager contentPathsInFolder:superFolderPath];
    }
    if (itemPaths.count == 0) {
        return;
    }
    
    // 重命名
    for (NSInteger i = 0; i < itemPaths.count; i++) {
        NSString *itemPath = itemPaths[i];
        NSString *newItemName = [NSString stringWithFormat:@"%@ %@", superFolderPath.lastPathComponent, itemPath.lastPathComponent];
        NSString *destItemPath = [superFolderPath.stringByDeletingLastPathComponent stringByAppendingPathComponent:newItemName];
        [MUBFileManager moveItemFromPath:itemPath toPath:destItemPath];
        
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"将: %@", itemPath];
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"重命名为: %@", destItemPath];
    }
    
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"将所有子文件夹的名称前加上根文件夹的名称, 流程结束"];
}

#pragma mark - MUBFileUniversalTypeCopyFolderHierarchy
+ (void)_copyFolderHierarchyWithRootFolderPath:(NSString *)rootFolderPath {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"复制文件夹的层级, 流程开始, 选择的根目录: %@", rootFolderPath];
    
    NSString *targetRootFolderPath = rootFolderPath.copy;
    if ([targetRootFolderPath hasSuffix:@"/"]) {
        targetRootFolderPath = [rootFolderPath substringToIndex:targetRootFolderPath.length - 1];
    }
    targetRootFolderPath = [targetRootFolderPath stringByAppendingString:@" 复制层级/"];
    [MUBFileManager createFolderAtPath:targetRootFolderPath];
    
    NSArray *allFolderPaths = [MUBFileManager allFolderPathsInFolder:rootFolderPath];
    for (NSInteger i = 0; i < allFolderPaths.count; i++) {
        NSString *folderPath = allFolderPaths[i];
        NSString *destFolderPath = [folderPath stringByReplacingOccurrencesOfString:rootFolderPath withString:targetRootFolderPath];
        [MUBFileManager createFolderAtPath:destFolderPath];
    }
    
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"复制文件夹的层级, 流程结束"];
}

@end
