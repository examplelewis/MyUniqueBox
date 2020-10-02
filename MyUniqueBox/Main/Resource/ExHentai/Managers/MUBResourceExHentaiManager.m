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
#import "MUBResourceExHentaiImagesManager.h"
#import "MUBResourceExHentaiPagesManager.h"
#import "MUBResourceExHentaiTorrentsManager.h"

@interface MUBResourceExHentaiManager () <MUBResourceExHentaiPagesDelegate, MUBResourceExHentaiImagesDelegate>

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
            
        }
            break;
        case MUBResourceExHentaiTypePixivURLs: {
            
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

- (void)_startFetchingTorrents {
    
}

- (void)_startFetchingPixivURLs {
    
}

#pragma mark - MUBResourceExHentaiPagesDelegate
- (void)manager:(MUBResourceExHentaiPagesManager *)manager model:(MUBResourceExHentaiPageModel *)model didGetAllUrls:(NSArray<NSString *> *)urls error:(NSError * _Nullable)error {
    [self _startFetchingImagesWithInputs:[NSOrderedSet orderedSetWithArray:urls].array model:model];
}

#pragma mark - MUBResourceExHentaiImagesDelegate
- (void)manager:(MUBResourceExHentaiImagesManager *)manager model:(MUBResourceExHentaiPageModel *)model didGetAllImageURLs:(NSArray<NSString *> *)imageURLs error:(NSError *)error {
    if (imageURLs.count == 0) {
        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"没有获取到可用的图片地址，流程结束"];
        return;
    }
    
    MUBDownloadSettingModel *downloadSettingModel = [MUBDownloadSettingManager defaultManager].defaultPrefModel;
    downloadSettingModel.downloadFolderPath = [[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:[NSString stringWithFormat:@"ExHentai/%@", model.title]];
    
    MUBDownloadManager *downloadManager = [MUBDownloadManager managerWithSettingModel:downloadSettingModel URLs:imageURLs downloadFilePath:nil];
    downloadManager.onFinish = ^{
        [MUBFileManager trashFilePath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourceExHentaiSuccessPagesFilePath]];
//        [MUBFileManager trashFilePath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourceExHentaiSuccessImagesFilePath]];
    };
    [downloadManager start];
}
- (void)manager:(MUBResourceExHentaiImagesManager *)manager model:(MUBResourceExHentaiPageModel *)model didGetOneImageURL:(NSString *)imageURL error:(NSError *)error {
    
}

@end
