//
//  MUBDownloadManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/23.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBDownloadManager.h"
#import <AFNetworking/AFNetworking.h>
#import "MUBDownloadOperation.h"

static NSString * kDownloadRemainURLsExportFileName = @"MUBDownloadRemainURLsExportFile.txt";

@interface MUBDownloadManager ()

@property (strong) MUBDownloadSettingModel *model;
@property (copy) NSArray<NSString *> *URLs; // 输入的链接, 不会变
@property (copy) NSString *downloadFilePath;
@property (assign) NSInteger redownloadTimes;

@property (strong) NSMutableArray<NSString *> *remainURLs; // 还未下载的链接
@property (strong) NSMutableArray<NSString *> *successURLs; // 下载成功的链接
// URLs.count = successURLs.count + remainURLs.count;

@property (strong) NSString *remainURLsExportFilePath;

@property (strong) AFURLSessionManager *manager;
@property (strong) NSOperationQueue *opQueue;

@end

@implementation MUBDownloadManager

#pragma mark - Lifecycle
+ (instancetype)managerWithSettingModel:(MUBDownloadSettingModel *)model URLs:(NSArray<NSString *> *)URLs downloadFilePath:(NSString * _Nullable)downloadFilePath {
    MUBDownloadManager *manager = [MUBDownloadManager new];
    
    manager.model = model;
    manager.URLs = URLs;
    manager.downloadFilePath = downloadFilePath.isEmpty ? nil : downloadFilePath;
    manager.redownloadTimes = 0;
    
    manager.remainURLs = [URLs mutableCopy];
    manager.successURLs = [NSMutableArray array];
    
    if ([manager.model.downloadFolderPath isEqualToString:[MUBSettingManager defaultManager].downloadFolderPath]) {
        manager.remainURLsExportFilePath = [[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:@"MUBDownloadRemainURLsExportFile.txt"];
    } else {
        NSString *downloadFolderSuffix = [manager.model.downloadFolderPath stringByReplacingOccurrencesOfString:[MUBSettingManager defaultManager].downloadFolderPath withString:@""];
        downloadFolderSuffix = [downloadFolderSuffix stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
        manager.remainURLsExportFilePath = [[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:[NSString stringWithFormat:@"MUBDownloadRemainURLsExportFile %@.txt", downloadFolderSuffix]];
    }
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    manager.manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    manager.opQueue = [NSOperationQueue new];
    manager.opQueue.maxConcurrentOperationCount = manager.model.maxConcurrentCount;
    
    return manager;
}

- (void)start {
    // 创建下载文件夹
    if (![MUBFileManager createFolderAtPath:self.model.downloadFolderPath]) {
        [[MUBLogManager defaultManager] addErrorLogWithFormat:@"%@ 文件夹不存在且创建失败, 下载流程结束", self.model.downloadFolderPath];
        return;
    }
    
    [self _startWhetherIsFirstTime:YES];
}

- (void)_startWhetherIsFirstTime:(BOOL)isFirstTime {
    if (isFirstTime) {
        [[MUBLogManager defaultManager] reset];
        [[MUBUIManager defaultManager] resetProgressIndicatorMaxValue: (double)self.URLs.count];
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"下载流程开始，共 %ld 个文件", self.URLs.count];
    } else {
        [[MUBLogManager defaultManager] addNewlineLog];
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"第%ld次重新下载未成功的文件，共 %ld 个", self.redownloadTimes, self.URLs.count];
    }
    
    NSBlockOperation *completionOperation = [NSBlockOperation blockOperationWithBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{ // 回到主线程执行，方便更新 UI 等
            [self performSelector:@selector(_finishAllDownloadingOperations) withObject:nil afterDelay:0.1f];
        }];
    }];
    
    for (NSInteger i = 0; i < self.URLs.count; i++) {
        @weakify(self);
        NSURLSessionDownloadTask *downloadTask = [self _downloadTaskWithUrl:self.URLs[i] completion:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            @strongify(self);
            
            NSString *URL = self.URLs[i];
            if (error) {
//                if (error.downloadErrorType == MUBErrorTypeDownloadConnectionLost) {
//                    [[MUBLogManager defaultManager] addErrorLogWithFormat:@"链接: %@, 下载失败: %@，等待重新下载", URL, error.localizedDescription];
//                } else {
//                    [[MUBLogManager defaultManager] addErrorLogWithFormat:@"链接: %@, 下载失败: %@，无法重新下载", URL, error.localizedDescription];
//                }
                [[MUBLogManager defaultManager] addErrorLogWithFormat:@"链接: %@, 下载失败: %@，等待重新下载", URL, error.localizedDescription];
            } else {
                @synchronized (self) {
                    [self.successURLs addObject:URL];
                    
                    [self.remainURLs removeObject:URL];
                    [self.remainURLs exportToPath:self.remainURLsExportFilePath behavior:MUBFileOpertaionBehaviorExportNoneContent];
                    
                    [[MUBUIManager defaultManager] updateProgressIndicatorDoubleValue:(double)self.successURLs.count];
                }
            }
        }];
        
        MUBDownloadOperation *operation = [MUBDownloadOperation operationWithURLSessionTask:downloadTask];
        [completionOperation addDependency:operation];
        [_opQueue addOperation:operation];
    }
    
    [_opQueue addOperation:completionOperation];
}

- (void)_finishAllDownloadingOperations {
    if (self.remainURLs.count > 0 && self.redownloadTimes < self.model.maxRedownloadTimes) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"1秒后重新下载未成功的文件"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.redownloadTimes += 1;
            self.URLs = [self.remainURLs copy];
            
            [self _startWhetherIsFirstTime:NO];
        });
    } else {
        if (self.remainURLs.count == 0) {
            if ([MUBFileManager fileExistsAtPath:self.remainURLsExportFilePath]) {
                [MUBFileManager trashFilePath:self.remainURLsExportFilePath];
            }
        } else {
            [[MUBLogManager defaultManager] addWarningLogWithFormat:@"有 %ld 个文件仍然无法下载，列表已导出到下载文件夹中的 %@ 文件中", self.remainURLs.count, self.remainURLsExportFilePath.lastPathComponent];
        }
        
        if (self.downloadFilePath.isNotEmpty && [MUBFileManager fileExistsAtPath:self.downloadFilePath]) {
            [MUBFileManager trashFilePath:self.downloadFilePath];
        }
        
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"下载流程结束"];
        if (self.model.showFinishAlert) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MUBAlertManager showInfomationalAlertOnMainWindowWithMessage:@"下载流程结束" info:nil runModal:YES handler:nil];
            });
        }
        
        if ([self.delegate respondsToSelector:@selector(downloadManager:didFinishDownloading:)]) {
            [self.delegate downloadManager:self didFinishDownloading:YES];
        }
    }
}

- (NSURLSessionDownloadTask *)_downloadTaskWithUrl:(NSString *)url completion:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionBlock {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.timeoutInterval = self.model.timeoutInterval;
    request.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    if (self.model.httpHeaders) {
        for (NSString *key in self.model.httpHeaders) {
            [request setValue:self.model.httpHeaders[key] forHTTPHeaderField:key];
        }
    }
    
    NSURLSessionDownloadTask *downloadTask = [self.manager downloadTaskWithRequest:request progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *fileName;
        if (self.model.renameInfo.isNotEmpty) {
            fileName = self.model.renameInfo[url];
            if (fileName.isEmpty) {
                fileName = response.suggestedFilename;
            }
        } else {
            fileName = response.suggestedFilename;
        }
        NSString *filePath = [self.model.downloadFolderPath stringByAppendingPathComponent:fileName];
        
        // 如果文件存在的话，重命名
        for (NSInteger i = 1; i <= 100; i++) {
            if (![MUBFileManager fileExistsAtPath:filePath]) {
                break;
            }
            
            NSString *newFileName = [NSString stringWithFormat:@"%@ %ld.%@", fileName.stringByDeletingPathExtension, i, fileName.pathExtension];
            filePath = [self.model.downloadFolderPath stringByAppendingPathComponent:newFileName];
        }
        
        return [NSURL fileURLWithPath:filePath];
    } completionHandler:completionBlock];
    
    return downloadTask;
}

@end
