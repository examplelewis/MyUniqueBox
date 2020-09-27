//
//  MUBMenuItemDownloadManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/26.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBMenuItemDownloadManager.h"
#import "MUBDownloadManager.h"
#import "MUBDownloadSettingManager.h"

@implementation MUBMenuItemDownloadManager

+ (void)customMenuItemDidPress:(NSMenuItem *)sender {
    MUBDownloadSettingModel *prefModel = [[MUBDownloadSettingManager defaultManager] prefModelFromMenuItemTag:sender.tag];
    if (!prefModel) {
        [[MUBLogManager defaultManager] addErrorLogWithFormat:@"未找到匹配的配置文件，下载流程结束"];
        return;
    }
    
    if (prefModel.fileMode == MUBDownloadSettingFileModeInput) {
        NSString *URLString = [MUBUIManager defaultManager].viewController.inputTextView.string;
        [MUBMenuItemDownloadManager _createDownloadManagerFromPrefModel:prefModel URLString:URLString downloadFilePath:nil];
    } else if (prefModel.fileMode == MUBDownloadSettingFileModeChooseFile) {
        [MUBOpenPanelManager showOpenPanelOnMainWindowWithBehavior:MUBOpenPanelBehaviorSingleFile message:@"请选择包含下载链接的文件，目前只支持txt" prompt:@"确定" fileTypes:@[@"txt"] handler:^(NSOpenPanel * _Nonnull openPanel, NSModalResponse result) {
            if (result == NSModalResponseOK) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *path = [MUBFileManager pathFromOpenPanelURL:openPanel.URLs.firstObject];
                    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"已选择：%@", path];
                    
                    NSError *error;
                    NSString *URLString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
                    if (error) {
                        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"读取TXT文件失败: %@, 下载流程结束", error.localizedDescription];
                        return;
                    }
                    
                    [MUBMenuItemDownloadManager _createDownloadManagerFromPrefModel:prefModel URLString:URLString downloadFilePath:path];
                });
            }
        }];
    } else {
        [[MUBLogManager defaultManager] addErrorLogWithFormat:@"未找到匹配的输入方式，下载流程结束"];
    }
}

+ (void)_createDownloadManagerFromPrefModel:(MUBDownloadSettingModel *)prefModel URLString:(NSString *)URLString downloadFilePath:(NSString * _Nullable)downloadFilePath {
    if (URLString.length == 0) {
        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"未读取到可用的下载链接, 下载流程结束"];
        return;
    }
    
    NSArray *URLs = [URLString componentsSeparatedByString:@"\n"];
    MUBDownloadManager *manager = [MUBDownloadManager managerWithSettingModel:prefModel URLs:URLs downloadFilePath:downloadFilePath];
    [manager start];
}

@end
