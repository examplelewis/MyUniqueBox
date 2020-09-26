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

static NSString * kDownloadSuccessURLsExportFileName = @"MUBDownloadSuccessURLsExportFile.txt";
static NSString * kDownloadFailedURLsExportFileName = @"MUBDownloadFailedURLsExportFile.txt";
static NSString * kDownloadRemainURLsExportFileName = @"MUBDownloadRemainURLsExportFile.txt";

@interface MUBDownloadManager ()

@property (strong) MUBDownloadSettingModel *model;
@property (copy) NSArray<NSString *> *URLs; // 输入的链接, 不会变

@property (strong) AFURLSessionManager *manager;
@property (strong) NSOperationQueue *opQueue;

@property (strong) NSString *failedURLsExportFilePath;
@property (strong) NSString *remainURLsExportFilePath;

@property (assign) NSInteger redownloadTimes;

@property (copy) NSArray<NSString *> *downloadURLs; // 当前下载的所有链接
@property (strong) NSMutableArray<NSString *> *successURLs; // 下载成功的链接
@property (strong) NSMutableArray<NSString *> *failedURLs; // 下载失败的链接
@property (strong) NSMutableArray<NSString *> *remainURLs; // 还未下载的链接
// downlaodURLs.count = successURLs.count + failedURLs.count + remainURLs.count;

@end

@implementation MUBDownloadManager

#pragma mark - Lifecycle
- (instancetype)initWithSettingModel:(MUBDownloadSettingModel *)model URLs:(NSArray<NSString *> *)URLs {
    self = [super init];
    if (self) {
        self.model = model;
        self.URLs = URLs;
        self.redownloadTimes = 0;
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        
        if ([self.model.downloadFolderPath isEqualToString:[MUBSettingManager defaultManager].downloadFolderPath]) {
            self.failedURLsExportFilePath = [[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:@"MUBDownloadFailedURLsExportFile.txt"];
            self.remainURLsExportFilePath = [[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:@"MUBDownloadRemainURLsExportFile.txt"];
        } else {
            NSString *downloadFolderSuffix = [self.model.downloadFolderPath stringByReplacingOccurrencesOfString:[MUBSettingManager defaultManager].downloadFolderPath withString:@""];
            downloadFolderSuffix = [downloadFolderSuffix stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
            
            self.failedURLsExportFilePath = [[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:[NSString stringWithFormat:@"MUBDownloadFailedURLsExportFile %@.txt", downloadFolderSuffix]];
            self.remainURLsExportFilePath = [[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:[NSString stringWithFormat:@"MUBDownloadRemainURLsExportFile %@.txt", downloadFolderSuffix]];
        }
        
        self.opQueue = [NSOperationQueue new];
        self.opQueue.maxConcurrentOperationCount = self.model.maxConcurrentCount;
        
        self.downloadURLs = [URLs copy];
    }
    
    return self;
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
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"第%ld次下载失败链接，共 %ld 个文件", self.redownloadTimes, self.downloadURLs.count];
    }
    
    self.successURLs = [NSMutableArray array];
    self.failedURLs = [NSMutableArray array];
    self.remainURLs = [self.downloadURLs mutableCopy];
    
    NSBlockOperation *completionOperation = [NSBlockOperation blockOperationWithBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{ // 回到主线程执行，方便更新 UI 等
            [self performSelector:@selector(_finishAllDownloadingOperations) withObject:nil afterDelay:0.1f];
        }];
    }];
    
    for (NSInteger i = 0; i < self.downloadURLs.count; i++) {
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
                
                @synchronized (self) {
                    [self.failedURLs addObject:URL];
                    [self.remainURLs removeObject:URL];
                    
                    [self.failedURLs exportToPath:self.failedURLsExportFilePath];
                    [self.remainURLs exportToPath:self.remainURLsExportFilePath behavior:MUBFileOpertaionBehaviorExportNoneContent];
                    
                    [[MUBUIManager defaultManager] updateProgressIndicatorDoubleValue:(double)(self.successURLs.count + self.failedURLs.count)];
                }
            } else {
                @synchronized (self) {
                    [self.successURLs addObject:URL];
                    [self.remainURLs removeObject:URL];
                    
                    [self.remainURLs exportToPath:self.remainURLsExportFilePath behavior:MUBFileOpertaionBehaviorExportNoneContent];
                    
                    [[MUBUIManager defaultManager] updateProgressIndicatorDoubleValue:(double)(self.successURLs.count + self.failedURLs.count)];
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
    if (self.failedURLs.count > 0 && self.redownloadTimes < self.model.maxRedownloadTimes) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"1秒后重新下载失败的图片"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.redownloadTimes += 1;
            self.downloadURLs = [self.failedURLs copy];
            
            [self _startWhetherIsFirstTime:NO];
        });
    } else {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"下载流程结束"];
        if (self.failedURLs.count > 0) {
            [[MUBLogManager defaultManager] addWarningLogWithFormat:@"有 %ld 个文件仍然无法下载，列表已导出到下载文件夹中的 %@ 文件中", self.failedURLs.count, self.failedURLsExportFilePath.lastPathComponent];
        }
        
//        if (self.remainURLs.count == 0 && [MUBFileManager fileExistsAtPath:self.remainURLsExportFilePath]) {
//            [MUBFileManager trashFilePath:self.remainURLsExportFilePath];
//        }
        
        if (self.model.showFinishAlert) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MUBAlertManager showInfomationalAlertOnMainWindowWithMessage:@"下载流程结束" info:nil runModal:NO handler:nil];
            });
        }
        
//        if (self.finishBlock) {
//            self.finishBlock();
//        }
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
    
    NSURLSessionDownloadTask *downloadTask = [self.manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
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
        return [NSURL fileURLWithPath:filePath];
    } completionHandler:completionBlock];
    
    return downloadTask;
}

@end
