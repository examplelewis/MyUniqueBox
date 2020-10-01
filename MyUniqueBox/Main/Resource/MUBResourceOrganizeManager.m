//
//  MUBResourceOrganizeManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/10/01.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBResourceOrganizeManager.h"
#import "MUBResourceWeiboHeader.h"

@interface MUBResourceOrganizeManager ()

@property (assign) MUBResourceOrganizeType type;
@property (copy) NSString *plistPath;

@property (copy) NSString *folderName;
@property (copy) NSString *folderPath;

@end

@implementation MUBResourceOrganizeManager

+ (instancetype)managerWithType:(MUBResourceOrganizeType)type plistPath:(NSString * _Nullable)plistPath {
    MUBResourceOrganizeManager *manager = [[MUBResourceOrganizeManager alloc] initWithType:type];
    if (plistPath.isNotEmpty) {
        manager.plistPath = plistPath;
    }
    
    return manager;
}
- (instancetype)initWithType:(MUBResourceOrganizeType)type {
    self = [super init];
    if (self) {
        switch (type) {
            case MUBResourceOrganizeTypeJDLingyu: {
                self.plistPath = @"";
                self.folderName = @"绝对领域";
            }
                break;
            case MUBResourceOrganizeTypeWeibo: {
                self.plistPath = [[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourceWeiboStatusFilePath];
                self.folderName = @"微博";
            }
                break;
            default:
                break;
        }
        self.folderPath = [[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:self.folderName];
    }
    
    return self;
}

- (void)start {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"整理流程开始"];
    
    if (![MUBFileManager fileExistsAtPath:self.plistPath]) {
        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"plist不存在，请查看对应的文件夹"];
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"整理流程结束"];
        return;
    }
    
    // 如果文件夹存在，那么直接对文件夹进行处理；不存在，选择文件夹
    if ([MUBFileManager fileExistsAtPath:self.folderPath]) {
        [self _organizeImageFileInRootFolderPath:self.folderPath];
    } else {
        [MUBOpenPanelManager showOpenPanelOnMainWindowWithBehavior:MUBOpenPanelBehaviorSingleDir message:[NSString stringWithFormat:@"选择%@的下载文件夹", self.folderName] handler:^(NSOpenPanel * _Nonnull openPanel, NSModalResponse result) {
            if (result == NSModalResponseOK) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *folderPath = [MUBFileManager pathFromOpenPanelURL:openPanel.URLs.firstObject];
                    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"已选择%@的下载文件夹: %@", self.folderName, folderPath];
                    
                    [self _organizeImageFileInRootFolderPath:folderPath];
                });
            }
        }];
    }
}

- (void)_organizeImageFileInRootFolderPath:(NSString *)rootFolderPath {
    // 先查找文件夹里是否有图片文件。如果没有，可能是没有将图片文件移动到文件夹内，目前给出提示
    NSArray *imageFilePaths = [MUBFileManager filePathsInFolder:rootFolderPath extensions:[MUBSettingManager defaultManager].mimeImageTypes];
    if (imageFilePaths.count == 0) {
        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"没有在文件夹内找到图片文件，可能是没有将图片文件移动到文件夹内，请检查文件夹"];
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"整理流程结束"];
        return;
    }
    
    // 根据plist文件整理记录的图片
    NSDictionary *renameInfo = [NSDictionary dictionaryWithContentsOfFile:self.plistPath];
    for (NSString *folderName in [renameInfo allKeys]) {
        NSString *destFolderPath = [rootFolderPath stringByAppendingPathComponent:folderName];
        [MUBFileManager createFolderAtPath:destFolderPath];
        
        NSArray *imageURLs = [NSArray arrayWithArray:renameInfo[folderName]];
        for (NSString *imageURL in imageURLs) {
            NSString *imageFilePath = [rootFolderPath stringByAppendingPathComponent:imageURL.lastPathComponent];
            NSString *destFilePath = [destFolderPath stringByAppendingPathComponent:imageURL.lastPathComponent];
            [MUBFileManager moveItemFromPath:imageFilePath toPath:destFilePath];
            
//            [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"移动前: %@", imageFilePath];
//            [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"移动后: %@", destFilePath];
        }
    }
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"整理流程结束"];
    
    // 删除 plist 文件
    [MUBFileManager trashFilePath:self.plistPath];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MUBAlertManager showInfomationalAlertOnMainWindowWithMessage:@"整理流程结束" info:nil runModal:YES handler:nil];
    });
    
    if ([self.delegate respondsToSelector:@selector(managerDidFinishOrganizing:)]) {
        [self.delegate managerDidFinishOrganizing:self];
    }
}

@end
