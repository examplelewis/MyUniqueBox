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
        case MUBFileUniversalTypeRename32BitMD5ByFile:
        case MUBFileUniversalTypeRename32BitMD5BySeries: {
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
            message = @"需要复制层级的根目录";
        }
            break;
        case MUBFileUniversalTypeExtractSingleFolder:
        case MUBFileUniversalTypeExtractSingleFile: {
            behavior = MUBOpenPanelBehaviorSingleDir;
            message = @"需要提取的根目录";
        }
            break;
        case MUBFileUniversalTypeTrashNoItemsFolder: {
            behavior = MUBOpenPanelBehaviorSingleDir;
            message = @"需要清空没有项目的根目录";
        }
            break;
        case MUBFileUniversalTypeTrashAntiImageVideoFiles: {
            behavior = MUBOpenPanelBehaviorSingleDir;
            message = @"需要清空图片视频之外文件的根目录";
        }
            break;
        default:
            break;
    }
    if (behavior == MUBOpenPanelBehaviorNone) {
        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"MUBFileUniversalManager showOpenPanelWithType behavior == MUBOpenPanelBehaviorNone"];
    } else {
        [MUBFileUniversalManager _showOpenPanelWithType:type behavior:behavior message:message];
    }
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
                            [MUBFileUniversalManager _rename32BitMD5AtRootFolderPath:path byType:type];
                        }
                            break;
                        case MUBFileUniversalTypeRename32BitMD5BySeries: {
                            [MUBFileUniversalManager _renameSeries32BitMD5AtRootFolderPath:path];
                        }
                            break;
                        case MUBFileUniversalTypeSearchHiddenFile: {
                            [MUBFileUniversalManager _searchAndTrashHiddenContentsAtRootFolderPath:path];
                        }
                            break;
                        case MUBFileUniversalTypeRenameAsSuperFodlerNameOnSingleFolder:
                        case MUBFileUniversalTypeRenameAsSuperFodlerNameOnSingleFile:
                        case MUBFileUniversalTypeRenameAsSuperFodlerNameOnSingleContent: {
                            [MUBFileUniversalManager _renameSingleItemAsSuperFodlerNameAtRootFolderPath:path byType:type];
                        }
                            break;
                        case MUBFileUniversalTypeCopyFolderHierarchy: {
                            [MUBFileUniversalManager _copyFolderHierarchyAtRootFolderPath:path];
                        }
                            break;
                        case MUBFileUniversalTypeExtractSingleFolder:
                        case MUBFileUniversalTypeExtractSingleFile: {
                            [MUBFileUniversalManager _extractSingleItemAtRootFolderPath:path byType:type];
                        }
                            break;
                        case MUBFileUniversalTypeTrashNoItemsFolder: {
                            [MUBFileUniversalManager _trashNoItemsFolderAtRootFolderPath:path];
                        }
                            break;
                        case MUBFileUniversalTypeTrashAntiImageVideoFiles: {
                            [MUBFileUniversalManager _trashAntiImageVideoFilesAtRootFolderPath:path];
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
+ (void)operationWithType:(MUBFileUniversalType)type {
    switch (type) {
        case MUBFileUniversalTypeCombineMultipleFolders: {
            [MUBFileUniversalManager _combineMultipleFolders];
        }
            break;
        default:
            break;
    }
}

#pragma mark - MUBFileUniversalTypeRename32BitMD5
+ (void)_rename32BitMD5AtRootFolderPath:(NSString *)rootFolderPath byType:(MUBFileUniversalType)byType {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"为文件生成32位的随机名称, 流程开始, 选择的根目录: %@", rootFolderPath];
    
    NSArray *filePaths = [MUBFileManager allFilePathsInFolder:rootFolderPath];
    if (filePaths.count == 0) {
        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"为文件生成32位的随机名称, 流程结束: 选择的文件夹中没有项目"];
        return;
    }
    
    for (NSInteger i = 0; i < filePaths.count; i++) {
        NSString *filePath = filePaths[i];
        NSString *folderPath = filePath.stringByDeletingLastPathComponent;
        
        NSString *newFilePath = @"";
        if (byType == MUBFileUniversalTypeRename32BitMD5ByFolder) {
            NSString *folderMD5 = [self _md5MiddleStringFromPath:folderPath];
            NSString *fileMD5 = [self _md5MiddleStringFromPath:filePath];
            newFilePath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.%@", folderMD5, fileMD5, filePath.pathExtension]];
        } else if (byType == MUBFileUniversalTypeRename32BitMD5ByFile) {
            NSString *fileMD5 = [self _md5StringFromPath:filePath];
            newFilePath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", fileMD5, filePath.pathExtension]];
        }
        
        [MUBFileManager moveItemFromPath:filePath toPath:newFilePath];
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"\n重命名前：\t%@/%@\n重命名后：\t%@/%@", filePath.stringByDeletingLastPathComponent.lastPathComponent, filePath.lastPathComponent, newFilePath.stringByDeletingLastPathComponent.lastPathComponent, newFilePath.lastPathComponent];
    }
    
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"为文件生成32位的随机名称, 流程结束"];
}
+ (void)_renameSeries32BitMD5AtRootFolderPath:(NSString *)rootFolderPath {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"为文件生成32位的随机名称, 流程开始, 选择的根目录: %@", rootFolderPath];
    
    NSArray *seriesAllFolderPaths = [MUBFileManager folderPathsInFolder:rootFolderPath];
    for (NSString *seriesAllFolderPath in seriesAllFolderPaths) {
        NSString *seriesAllFolderMD5 = [self _md5Middle8StringFromPath:seriesAllFolderPath];
        NSArray *seriesFolderPaths = [MUBFileManager folderPathsInFolder:seriesAllFolderPath];
        for (NSString *seriesFolderPath in seriesFolderPaths) {
            NSString *seriesFolderMD5 = [self _md5Middle8StringFromPath:seriesFolderPath];
            NSArray *filePaths = [MUBFileManager filePathsInFolder:seriesFolderPath];
            for (NSString *filePath in filePaths) {
                NSString *fileMD5 = [self _md5MiddleStringFromPath:filePath];
                NSString *newFilePath = [seriesFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@%@.%@", seriesAllFolderMD5, seriesFolderMD5, fileMD5, filePath.pathExtension]];
                
                [MUBFileManager moveItemFromPath:filePath toPath:newFilePath];
                [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"\n重命名前：\t%@/%@\n重命名后：\t%@/%@", filePath.stringByDeletingLastPathComponent.lastPathComponent, filePath.lastPathComponent, newFilePath.stringByDeletingLastPathComponent.lastPathComponent, newFilePath.lastPathComponent];
            }
        }
    }
    
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"为文件生成32位的随机名称, 流程结束"];
}
+ (NSString *)_md5Middle8StringFromPath:(NSString *)path {
    NSDate *creationDate = [MUBFileManager attribute:NSFileCreationDate ofItemAtPath:path];
    NSString *desc = [NSString stringWithFormat:@"%@%@", path.lastPathComponent, creationDate];
    return desc.md5String.md5Middle8;
}
+ (NSString *)_md5MiddleStringFromPath:(NSString *)path {
    NSDate *creationDate = [MUBFileManager attribute:NSFileCreationDate ofItemAtPath:path];
    NSString *desc = [NSString stringWithFormat:@"%@%@", path.lastPathComponent, creationDate];
    return desc.md5String.md5Middle;
}
+ (NSString *)_md5StringFromPath:(NSString *)path {
    NSDate *creationDate = [MUBFileManager attribute:NSFileCreationDate ofItemAtPath:path];
    NSString *desc = [NSString stringWithFormat:@"%@%@", path.lastPathComponent, creationDate];
    return desc.md5String;
}

#pragma mark - MUBFileUniversalTypeSearchHiddenFile
+ (void)_searchAndTrashHiddenContentsAtRootFolderPath:(NSString *)rootFolderPath {
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
+ (void)_renameSingleItemAsSuperFodlerNameAtRootFolderPath:(NSString *)rootFolderPath byType:(MUBFileUniversalType)byType {
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
            [[MUBLogManager defaultManager] addWarningLogWithFormat:@"%@ 内没有项目, 跳过", folderPath];
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
        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"%@ 内没有项目, 跳过", superFolderPath];
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
+ (void)_copyFolderHierarchyAtRootFolderPath:(NSString *)rootFolderPath {
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

#pragma mark - MUBFileUniversalTypeExtractSingleItem
+ (void)_extractSingleItemAtRootFolderPath:(NSString *)rootFolderPath byType:(MUBFileUniversalType)byType {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"提取文件夹的单个项目, 流程开始, 选择的根目录: %@", rootFolderPath];
    
    NSString *extractRootFolderName = [NSString stringWithFormat:@"%@ Extract", rootFolderPath.lastPathComponent];
    NSString *extractRootFolderPath = [rootFolderPath.stringByDeletingLastPathComponent stringByAppendingPathComponent:extractRootFolderName];
    [MUBFileManager createFolderAtPath:extractRootFolderPath];
    
    NSArray *folderPaths = [MUBFileManager folderPathsInFolder:rootFolderPath];
    for (NSInteger i = 0; i < folderPaths.count; i++) {
        NSString *folderPath = folderPaths[i];
        
        NSArray *itemPaths = @[];
        if (byType == MUBFileUniversalTypeExtractSingleFolder) {
            itemPaths = [MUBFileManager folderPathsInFolder:folderPath];
        } else if (byType == MUBFileUniversalTypeExtractSingleFile) {
            itemPaths = [MUBFileManager filePathsInFolder:folderPath];
        }
        if (itemPaths.count == 0) {
            [[MUBLogManager defaultManager] addWarningLogWithFormat:@"%@ 内没有项目, 跳过", folderPath];
            continue;
        }
        if (itemPaths.count != 1) {
            [[MUBLogManager defaultManager] addWarningLogWithFormat:@"%@ 内有不止一个项目, 跳过", folderPath];
            continue;
        }
        
        NSString *itemPath = itemPaths.firstObject;
        NSString *destItemPath = [extractRootFolderPath stringByAppendingPathComponent:itemPath.lastPathComponent];
        [MUBFileManager moveItemFromPath:itemPath toPath:destItemPath];
        
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"提取: %@", itemPath];
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"至: %@", destItemPath];
        
        [MUBFileManager trashFilePath:folderPath];
    }
    
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"提取文件夹的单个项目, 流程结束"];
}

#pragma mark - MUBFileUniversalTypeTrashNoItemsFolder
+ (void)_trashNoItemsFolderAtRootFolderPath:(NSString *)rootFolderPath {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"清空没有项目的文件夹, 流程开始, 选择的根目录: %@", rootFolderPath];
    
    NSArray *folderPaths = [MUBFileManager allFolderPathsInFolder:rootFolderPath];
    for (NSInteger i = 0; i < folderPaths.count; i++) {
        NSString *folderPath = folderPaths[i];
        NSArray *contentPaths = [MUBFileManager contentPathsInFolder:folderPath];
        if (contentPaths.count != 0) {
            continue;
        }
        
        [MUBFileManager trashFilePath:folderPath];
        
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"将 %@ 移动到废纸篓", folderPath];
    }
    
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"清空没有项目的文件夹, 流程结束"];
}

#pragma mark - MUBFileUniversalTypeTrashAntiImageVideoFiles
+ (void)_trashAntiImageVideoFilesAtRootFolderPath:(NSString *)rootFolderPath {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"清空清空图片视频之外的文件, 流程开始, 选择的根目录: %@", rootFolderPath];
    
    NSArray *trashFilePaths = [MUBFileManager allFilePathsInFolder:rootFolderPath withoutExtensions:[MUBSettingManager defaultManager].mimeImageAndVideoTypes];
    [MUBFileManager trashFilePaths:trashFilePaths];
    
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"清空清空图片视频之外的文件, 流程结束"];
}

#pragma mark - MUBFileUniversalTypeCombineMultipleFolders
+ (void)_combineMultipleFolders {
    MUBAlert *alert = [MUBAlertManager alertWithStyle:NSAlertStyleInformational message:@"是否将相同名称的文件移动到废纸篓中" info:nil];
    [alert addButtonWithTitles:@[@"否", @"是"] keyEquivalents:@[MUBAlertEscapeKeyEquivalent, MUBAlertReturnKeyEquivalent]];
    [alert beginSheetModalForWindow:[NSApplication sharedApplication].mainWindow completionHandler:^(NSModalResponse returnCode) {
        [MUBFileUniversalManager _combineMultipleFoldersWithTrashDuplicateFiles:returnCode == 1001];
    }];
}
+ (void)_combineMultipleFoldersWithTrashDuplicateFiles:(BOOL)trashDuplicateFiles {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"合并多个文件夹, 流程开始"];
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"遇到相同名称的文件【%@移动】到废纸篓中", trashDuplicateFiles ? @"" : @"不"];
    
    NSString *inputString = [MUBUIManager defaultManager].viewController.inputTextView.string;
    NSArray *folderPaths = [inputString componentsSeparatedByString:@"\n"];
    folderPaths = [NSOrderedSet orderedSetWithArray:folderPaths].array; // 使用NSOrderedSet去重
    if (folderPaths.count < 2) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"请在输入框中输入多个[不同]文件夹路径并以换行符区分，且最后一个文件夹路径为目标文件夹路径。"];
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"合并多个文件夹, 流程结束"];
        return;
    }
    
    NSArray *sourceFolderPaths = [folderPaths subarrayWithRange:NSMakeRange(0, folderPaths.count - 1)]; // 源文件夹
    NSString *targetFolderPath = folderPaths.lastObject; // 目标文件夹
    NSMutableArray *trashFolderPaths = [NSMutableArray array];
    
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"输入的源文件夹路径为:\n%@", sourceFolderPaths.stringValue];
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"输入的目标文件夹路径为:\n%@", targetFolderPath];
    
    // 单纯的替换根文件夹
    for (NSInteger i = 0; i < sourceFolderPaths.count; i++) {
        NSString *sourceFolderPath = sourceFolderPaths[i];
        NSArray *sourceFilePaths = [MUBFileManager allFilePathsInFolder:sourceFolderPath];
        for (NSInteger j = 0; j < sourceFilePaths.count; j++) {
            NSString *sourceFilePath = sourceFilePaths[j];
            NSString *targetFilePath = [sourceFilePath stringByReplacingOccurrencesOfString:sourceFolderPath withString:targetFolderPath];

            // 如果目标文件存在，那么忽略
            if ([MUBFileManager fileExistsAtPath:targetFilePath]) {
                [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"%@ 文件已存在，移动到废纸篓", [sourceFilePath stringByReplacingOccurrencesOfString:sourceFolderPath withString:@""]];
                [trashFolderPaths addObject:sourceFilePath];

                continue;
            }

            // 先判断目标地址的父文件夹是否存在，如果不存在创建该文件夹
            if (![MUBFileManager contentIsFolderAtPath:targetFilePath.stringByDeletingLastPathComponent]) {
                [MUBFileManager createFolderAtPath:targetFilePath.stringByDeletingLastPathComponent];
            }

            [MUBFileManager moveItemFromPath:sourceFilePath toPath:targetFilePath];

            [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"将: %@", sourceFilePath];
            [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"合并至: %@", targetFilePath];
        }
    }

    [MUBFileManager trashFilePaths:trashFolderPaths];

    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"合并多个文件夹, 流程结束"];
}

@end
