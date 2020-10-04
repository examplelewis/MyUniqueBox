//
//  MUBResourceExHentaiManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/10/02.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBResourceExHentaiManager.h"
#import "MUBResourceExHentaiHeader.h"
#import "MUBResourceExHentaiModels.h"

#import "MUBCookieManager.h"
#import "MUBSQLiteExHentaiManager.h"
#import "MUBResourceExHentaiImagesManager.h"
#import "MUBResourceExHentaiPagesManager.h"
#import "MUBResourceExHentaiTorrentsManager.h"
#import "MUBResourceExHentaiCommentManager.h"

@interface MUBResourceExHentaiManager () <MUBResourceExHentaiPagesDelegate, MUBResourceExHentaiImagesDelegate, MUBResourceExHentaiTorrentsDelegate>

@end

@implementation MUBResourceExHentaiManager

#pragma mark - Lifecycle
+ (instancetype)defaultManager {
    static MUBResourceExHentaiManager *defaultManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [[self alloc] init];
    });
    
    return defaultManager;
}

- (void)startWithType:(MUBResourceExHentaiType)type {
    NSString *inputStr = [MUBUIManager defaultManager].viewController.inputTextView.string;
    if (!inputStr.isNotEmpty) {
        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"没有获得任何数据，请检查输入框"];
        return;
    }
    
    MUBCookieManager *cookieManager = [MUBCookieManager managerWithType:MUBCookieTypeExHentai];
    [cookieManager deleteCookieByName:@"yay"];
    [cookieManager writeCookies];
    
    switch (type) {
        case MUBResourceExHentaiTypePages: {
            [self _startFetchingPagesWithInput:inputStr];
        }
            break;
        case MUBResourceExHentaiTypeImages: {
            [self _startFetchingImagesWithInputs:[inputStr componentsSeparatedByString:@"\n"] model:nil];
        }
            break;
        case MUBResourceExHentaiTypeTorrents: {
            [self _startFetchingTorrentsWithInputs:[inputStr componentsSeparatedByString:@"\n"]];
        }
            break;
        case MUBResourceExHentaiTypePixivURLs: {
            [self _startFetchingPixivURLsWithInputs:[inputStr componentsSeparatedByString:@"\n"]];
        }
            break;
        default:
            break;
    }
}
- (void)_startFetchingPagesWithInput:(NSString *)input {
    MUBResourceExHentaiPagesManager *manager = [MUBResourceExHentaiPagesManager managerFromPageURL:input];
    manager.delegate = self;
    [manager start];
}
- (void)_startFetchingImagesWithInputs:(NSArray *)inputs model:(MUBResourceExHentaiPageModel * _Nullable)model {
    MUBResourceExHentaiImagesManager *manager = [MUBResourceExHentaiImagesManager managerWithURLs:inputs];
    manager.delegate = self;
    if (model) {
        manager.model = model;
    }
    [manager start];
}
- (void)_startFetchingTorrentsWithInputs:(NSArray *)inputs {
    MUBResourceExHentaiTorrentsManager *manager = [MUBResourceExHentaiTorrentsManager managerWithURLs:inputs];
    manager.delegate = self;
    [manager start];
}
- (void)_startFetchingPixivURLsWithInputs:(NSArray *)inputs {
    MUBResourceExHentaiCommentManager *manager = [MUBResourceExHentaiCommentManager managerWithURLs:inputs];
    [manager start];
}

#pragma mark - MUBResourceExHentaiPagesDelegate
- (void)manager:(MUBResourceExHentaiPagesManager *)manager model:(MUBResourceExHentaiPageModel *)model didGetAllUrls:(NSArray<NSString *> *)urls error:(NSError * _Nullable)error {
    [self _startFetchingImagesWithInputs:[NSOrderedSet orderedSetWithArray:urls].array model:model];
}

#pragma mark - MUBResourceExHentaiImagesDelegate
- (void)manager:(MUBResourceExHentaiImagesManager *)manager model:(MUBResourceExHentaiPageModel *)model didGetAllImageModels:(NSArray<MUBResourceExHentaiImageModel *> *)imageModels error:(NSError *)error {
    if (imageModels.count == 0) {
        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"没有获取到可用的图片地址，流程结束"];
        return;
    }
    
    NSString *downloadFolderPath = [[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:[NSString stringWithFormat:@"ExHentai/%@", model.title]];
    
    // 从接口获取到的信息没有dgid，根据uploader和title获取dgid，没有的话在总数上加1
    NSInteger dgid = [[MUBSQLiteExHentaiManager defaultManager] getDGIDWithExHentaiPageModel:model];
    if (dgid == MUBErrorCodeSQLiteExHentaiHentaiFoundaryExceptionFound) {
        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"当前获取的标题: %@, 包含 HentaiFoundary 关注的画师，跳过", model.title];
        return;
    }
    model.dgid = dgid;
    NSArray<MUBResourceExHentaiImageModel *> *filteredImageModels = [[MUBSQLiteExHentaiManager defaultManager] filteredExHentaiImageModelsFrom:imageModels model:model];
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"本次流程一共抓取到 %ld 条图片信息, 数据库中共有 %ld 条重复, 去重后还剩 %ld 条记录", imageModels.count, imageModels.count - filteredImageModels.count, filteredImageModels.count];
    if (filteredImageModels.count == 0) {
        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"本次流程抓取到图片信息均在数据库中有记录, 流程结束"];
        return;
    }
    
    // 修改 model 的下载数量，如果下载数量和抓取数量不一致，添加备注
    model.downloadCount = filteredImageModels.count;
    if (imageModels.count != filteredImageModels.count) {
        model.remarks = [model.remarks arrayByAddingObject:[NSString stringWithFormat:@"数据库中共有 %ld 条重复", imageModels.count - filteredImageModels.count]];
    }
    
    [[MUBSQLiteExHentaiManager defaultManager] insertExHentaiImageModels:filteredImageModels model:model downloadFolderPath:downloadFolderPath];
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"已向数据库中添加 1 条页面记录和 %ld 条图片信息", filteredImageModels.count];
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"即将开始下载"];
    
    // 下载
    MUBDownloadSettingModel *downloadSettingModel = [MUBDownloadSettingManager defaultManager].defaultPrefModel;
    downloadSettingModel.downloadFolderPath = downloadFolderPath;

    MUBDownloadManager *downloadManager = [MUBDownloadManager managerWithSettingModel:downloadSettingModel URLs:[filteredImageModels valueForKey:@"downloadURL"] downloadFilePath:nil];
    downloadManager.onFinish = ^{
        [MUBFileManager trashFilePath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourceExHentaiSuccessPagesFilePath]];
        [MUBFileManager trashFilePath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourceExHentaiSuccessImagesFilePath]];
    };
    [downloadManager start];
}
- (void)manager:(MUBResourceExHentaiImagesManager *)manager model:(MUBResourceExHentaiPageModel *)model didGetOneImageModel:(MUBResourceExHentaiImageModel *)imageModel error:(NSError *)error {
    
}

#pragma mark - MUBResourceExHentaiTorrentsDelegate
- (void)manager:(MUBResourceExHentaiTorrentsManager *)manager didGetAllTorrentURLs:(NSArray<NSString *> *)URLs renameInfo:(NSDictionary *)renameInfo error:(NSError *)error {
    if (URLs.count == 0) {
        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"没有获取到可用的种子地址，流程结束"];
        return;
    }
    
    MUBDownloadSettingModel *downloadSettingModel = [MUBDownloadSettingManager defaultManager].defaultPrefModel;
    downloadSettingModel.downloadFolderPath = [[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:@"ExHentai Torrents"];
    downloadSettingModel.renameInfo = renameInfo.copy;
    
    MUBDownloadManager *downloadManager = [MUBDownloadManager managerWithSettingModel:downloadSettingModel URLs:URLs downloadFilePath:nil];
    downloadManager.onFinish = ^{
        [MUBFileManager trashFilePath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourceExHentaiSuccessTorrentsFilePath]];
    };
    [downloadManager start];
}

@end
