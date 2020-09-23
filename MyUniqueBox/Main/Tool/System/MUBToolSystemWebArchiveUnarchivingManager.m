//
//  MUBToolSystemWebArchiveUnarchivingManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/23.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBToolSystemWebArchiveUnarchivingManager.h"
#import <DTWebArchive/DTWebArchive.h>

@interface MUBToolSystemWebArchiveUnarchivingManager ()

@property (strong) NSMutableArray *destFolderPaths;

@end

@implementation MUBToolSystemWebArchiveUnarchivingManager

- (void)showOpenPanel {
    [MUBOpenPanelManager showOpenPanelOnMainWindowWithBehavior:MUBOpenPanelBehaviorMultipleFile message:@"请选择需要解析的WebArchive文件" prompt:@"确定" fileTypes:@[@"webarchive"] handler:^(NSOpenPanel * _Nonnull openPanel, NSModalResponse result) {
        if (result == NSModalResponseOK) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self _unarchiveWebArchiveFilesAtFilePaths:openPanel.URLs];
            });
        }
    }];
}

- (void)_unarchiveWebArchiveFilesAtFilePaths:(NSArray<NSURL *> *)URLs {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"解析WebArchive文件, 流程开始"];
    
    self.destFolderPaths = [NSMutableArray new];
    NSMutableArray *fileURLs = [NSMutableArray new];
    
    for (NSInteger i = 0; i < URLs.count; i++) {
        NSString *filePath = [MUBFileManager pathFromOpenPanelURL:URLs[i]];
        [fileURLs addObject:URLs[i]];
        [self _unarchiveWebArchiveFileAtFilePath:filePath];
    }
    
    // 删除 WebArchive 文件
    [[NSWorkspace sharedWorkspace] recycleURLs:fileURLs completionHandler:^(NSDictionary<NSURL *,NSURL *> * _Nonnull newURLs, NSError * _Nullable error) {
        if (!error) {
            [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"将 %ld 个 WebArchive 文件移动到废纸篓", newURLs.count];
        } else {
            [[MUBLogManager defaultManager] addErrorLogWithFormat:@"将 WebArchive 文件移动到废纸篓时发生错误：%@", error.localizedDescription];
        }

        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"解析WebArchive文件, 流程结束"];
    }];
}
- (void)_unarchiveWebArchiveFileAtFilePath:(NSString *)filePath {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"开始处理文件：%@", filePath];
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    DTWebArchive *archive = [[DTWebArchive alloc] initWithData:data];
    NSArray<DTWebResource *> *subResources = [archive.subresources filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(DTWebResource * _Nullable resource, NSDictionary<NSString *,id> * _Nullable bindings) {
        // 目前只导出大于25KB的图片文件
        return [[MUBSettingManager defaultManager] isImageAtFilePath:resource.URL.absoluteString] && resource.data.length > 25600;
    }]];
    
    if (subResources.count == 0) {
        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"%@ 归档文件中没有大于25KB的图片文件, 跳过", filePath];
        return;
    }
    
    NSString *destFolderPath = filePath.stringByDeletingPathExtension;
    [self.destFolderPaths addObject:destFolderPath];
    [MUBFileManager createFolderAtPath:destFolderPath];
    
    for (NSInteger i = 0; i < subResources.count; i++) {
        DTWebResource *resource = subResources[i];
        
        NSString *filePath = @"";
        if (resource.URL.lastPathComponent) {
            filePath = [destFolderPath stringByAppendingPathComponent:resource.URL.lastPathComponent];
        } else if (resource.URL.query) {
            filePath = [destFolderPath stringByAppendingPathComponent:resource.URL.query];
        } else {
            filePath = [destFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.%@", i, [resource.MIMEType componentsSeparatedByString:@"/"]]];
        }
        
        NSError *error;
        BOOL success = [resource.data writeToFile:filePath options:NSDataWritingAtomic error:&error];
        if (success) {
            [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"写入文件：%@, 成功", filePath];
        } else {
            [[MUBLogManager defaultManager] addErrorLogWithFormat:@"写入文件：%@, 发生错误：%@", filePath, error.localizedDescription];
        }
    }
}
- (void)trashSmallSizeImages {
    NSMutableArray<NSString *> *imageFilePaths = [NSMutableArray new];
    for (NSInteger i = 0; i < self.destFolderPaths.count; i++) {
        NSString *targetFolderPath = self.destFolderPaths[i];
        NSArray<NSString *> *targetImageFilePaths = [MUBFileManager filePathsInFolder:targetFolderPath extensions:[MUBSettingManager defaultManager].mimeImageTypes];
        [imageFilePaths addObjectsFromArray:targetImageFilePaths];
    }
    
    NSMutableArray<NSURL *> *trashes = [NSMutableArray array];
    for (NSString *imageFilePath in imageFilePaths) {
        NSImageRep *imageRep = [NSImageRep imageRepWithContentsOfFile:imageFilePath];
        NSSize size = NSMakeSize(imageRep.pixelsWide, imageRep.pixelsHigh);
        if (size.width < 801 && size.height < 801) {
            [trashes addObject:[NSURL fileURLWithPath:imageFilePath]];
        }
    }
    
    [[NSWorkspace sharedWorkspace] recycleURLs:trashes completionHandler:^(NSDictionary<NSURL *,NSURL *> * _Nonnull newURLs, NSError * _Nullable error) {
        if (!error) {
            [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"成功删除了 %ld 个尺寸过小的图片", newURLs.count];
        } else {
            [[MUBLogManager defaultManager] addErrorLogWithFormat:@"删除尺寸过小的图片时发生错误：%@", error.localizedDescription];
        }
    }];
}

@end
