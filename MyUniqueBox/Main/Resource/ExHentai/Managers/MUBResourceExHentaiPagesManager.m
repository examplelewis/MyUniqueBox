//
//  MUBResourceExHentaiPagesManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/10/02.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBResourceExHentaiPagesManager.h"
#import "MUBHTTPExHentaiManager.h"
#import <hpple/TFHpple.h>
#import "MUBResourceExHentaiHeader.h"

@interface MUBResourceExHentaiPagesManager ()

@property (nonatomic, copy) NSString *pageURL;

@property (copy) NSString *URL;
@property (copy) NSString *title;
@property (assign) NSInteger startPage;
@property (assign) NSInteger endPage;
@property (strong) MUBResourceExHentaiPageModel *model;

@property (strong) NSMutableArray *pages;
@property (strong) NSMutableArray *urls;
@property (strong) NSMutableArray *failures;

@property (assign) NSInteger download;

@end

@implementation MUBResourceExHentaiPagesManager

#pragma mark - Lifecycle
+ (instancetype)managerFromPageURL:(NSString *)pageURL {
    MUBResourceExHentaiPagesManager *manager = [MUBResourceExHentaiPagesManager new];
    manager.pageURL = pageURL;
    return manager;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.urls = [NSMutableArray array];
        self.failures = [NSMutableArray array];
        
        self.download = 0;
    }
    
    return self;
}

- (void)start {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"获取ExHentai图包信息, 流程开始"];
    [self _fetchPostDetail];
}
- (void)_fetchPostDetail {
    [[MUBHTTPExHentaiManager defaultManager] getPostDetailWithPageURL:self.URL completionHandler:^(NSURLResponse * _Nonnull response, NSArray<MUBResourceExHentaiPageModel *> * _Nullable models, NSError * _Nullable error) {
        if (error) {
            [MUBAlertManager showCriticalAlertOnMainWindowWithMessage:@"ExHentai 接口调用失败" info:error.localizedDescription runModal:NO handler:nil];
            return;
        }
        
        if (models.count == 0) {
            [[MUBLogManager defaultManager] addWarningLogWithFormat:@"接口未返回图包的信息, 流程结束"];
            return;
        }
        
        self.model = models.firstObject;
        NSInteger pageCount = ceilf(self.model.filecount / 20.0f);
        if (self.startPage > pageCount) {
            [[MUBLogManager defaultManager] addWarningLogWithFormat:@"起始页大于总页数: %ld, 图片总数: %ld", pageCount, self.model.filecount];
            return;
        }
        if (self.endPage > pageCount) {
            [[MUBLogManager defaultManager] addWarningLogWithFormat:@"截止页大于总页数: %ld, 图片总数: %ld", pageCount, self.model.filecount];
            return;
        }
        if (self.endPage == -1) {
            self.endPage = pageCount;
        }
        self.title = self.model.title;
        
        NSInteger startCount = self.startPage * 20;
        NSInteger endCount = self.endPage * 20;
        if (endCount > self.model.filecount) {
            endCount = self.model.filecount;
        }
        self.model.fetchCount = endCount - startCount;
        self.model.startPage = self.startPage + 1;
        self.model.endPage = self.endPage;
        
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"已获取到ExHentai图包信息:"];
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"title: %@", self.model.title];
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"titleJpn: %@", self.model.titleJpn];
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"fileCount: %ld", self.model.filecount];
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"category: %@", self.model.category];
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"rating: %@", self.model.rating];
        
        [self _fetchExHentaiPage];
    }];
}
- (void)_fetchExHentaiPage {
    for (NSInteger i = self.startPage; i < self.endPage; i++) {
        NSString *urlString = [self.URL stringByAppendingFormat:@"?p=%ld", i];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:60.0f];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                [[MUBLogManager defaultManager] addErrorLogWithFormat:@"获取网页原始数据失败，原因: %@", error.localizedDescription];
                
                [self.failures addObject:[self.URL stringByAppendingFormat:@"?p=%ld", i]];
                [self.failures exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourceExHentaiFailurePagesFilePath]];
            } else {
                TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
                NSArray *aArray = [xpathParser searchWithXPathQuery:@"//a"];
                for (TFHppleElement *element in aArray) {
                    NSString *hrefStr = [element.attributes objectForKey:@"href"];
                    if ([hrefStr hasPrefix:@"https://exhentai.org/s/"] || [hrefStr hasPrefix:@"https://e-hentai.org/s/"]) {
                        [self.urls addObject:hrefStr];
                    }
                }
                
                [self.urls exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourceExHentaiSuccessPagesFilePath]];
            }
            
            [self _didFinishDownloadingOneWebpage];
        }];
        [task resume];
    }
}
- (void)_didFinishDownloadingOneWebpage {
    self.download += 1;
    if (self.download != self.endPage - self.startPage) {
        return;
    }
    
    if (self.urls.count == 0) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"没有获取到包含图片的网页地址"];
//        // 提醒 Cookie 过期
//        if ([[NSDate date] timeIntervalSince1970] > 1541415982.704804) {
//            [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"如果确认操作无误，有可能是ExHentai的Cookie过期了，请重新在Chrome中刷新Cookie。Cookie预计到期时间：2018年11月05日"];
//        }
        return;
    }
    
    if (self.failures.count > 0) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"有%ld个页面无法解析，已导出到下载文件夹的 MUBResourceExHentaiFailurePages.txt 文件中", self.failures.count];
    }
    
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"已获取到%lu条包含图片的网页地址", self.urls.count];
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"即将获取上述网页中的图片链接"];
    
    if ([self.delegate respondsToSelector:@selector(manager:model:didGetAllUrls:error:)]) {
        [self.delegate manager:self model:self.model didGetAllUrls:self.urls.copy error:nil];
    }
}

#pragma mark - Setter
- (void)setPageURL:(NSString *)pageURL {
    _pageURL = [pageURL copy];
    
    NSArray *pageURLComps = [pageURL componentsSeparatedByString:@"|"];
    _URL = pageURLComps[0];
    if (pageURLComps.count >= 2) {
        _startPage = [pageURLComps[1] integerValue] - 1;
    } else {
        _startPage = 0;
    }
    if (pageURLComps.count >= 3) {
        _endPage = [pageURLComps[2] integerValue];
    } else {
        _endPage = -1;
    }
}

@end
