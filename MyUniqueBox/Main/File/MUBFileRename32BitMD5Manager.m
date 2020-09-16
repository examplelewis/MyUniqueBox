//
//  MUBFileRename32BitMD5Manager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/16.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBFileRename32BitMD5Manager.h"

@implementation MUBFileRename32BitMD5Manager

- (void)showOpenPanelWithByType:(MUBFileRename32BitMD5ByType)byType {
    [MUBOpenPanelManager showOpenPanelOnMainWindowWithBehavior:MUBOpenPanelBehaviorSingleDir message:@"请选择需要生成名称的文件根目录" handler:^(NSOpenPanel * _Nonnull openPanel, NSModalResponse result) {
        if (result == NSModalResponseOK) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *path = [MUBFileManager pathFromOpenPanelURL:openPanel.URLs.firstObject];
                [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"已选择的根目录：%@", path];
                
                [self _startWithRootFolder:path byType:byType];
            });
        }
    }];
}

- (void)_startWithRootFolder:(NSString *)rootFolder byType:(MUBFileRename32BitMD5ByType)byType {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"为图片等文件生成32位的随机名称, 流程开始, 选择的根目录: %@", rootFolder];
    
    NSArray *filePaths;
    if (byType == MUBFileRename32BitMD5ByTypeByFolder) {
        filePaths = [MUBFileManager allFilePathsInFolder:rootFolder];
    } else if (byType == MUBFileRename32BitMD5ByTypeByFile) {
        filePaths = [MUBFileManager filePathsInFolder:rootFolder];
    }
    if (filePaths.count == 0) {
        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"为图片等文件生成32位的随机名称, 流程失败: 选择的文件夹中没有文件"];
    }
    
    for (NSInteger i = 0; i < filePaths.count; i++) {
        NSString *filePath = filePaths[i];
        NSString *folderPath = filePath.stringByDeletingLastPathComponent;
        
        NSString *folderMD5 = [self md5MiddleStringFromPath:folderPath];
        NSString *fileMD5 = [self md5MiddleStringFromPath:filePath];
        NSString *newFilePath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.%@", folderMD5, fileMD5, filePath.pathExtension]];
        
        [MUBFileManager moveItemFromPath:filePath toPath:newFilePath];
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"\n重命名前：\t%@/%@\n重命名后：\t%@/%@", filePath.stringByDeletingLastPathComponent.lastPathComponent, filePath.lastPathComponent, newFilePath.stringByDeletingLastPathComponent.lastPathComponent, newFilePath.lastPathComponent];
    }
    
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"为图片等文件生成32位的随机名称, 流程结束"];
}

- (NSString *)md5MiddleStringFromPath:(NSString *)path {
    NSDate *creationDate = [MUBFileManager attribute:NSFileCreationDate ofItemAtPath:path];
    NSString *desc = [NSString stringWithFormat:@"%@%@", path.lastPathComponent, creationDate];
    return desc.md5String.md5Middle;
}

@end
