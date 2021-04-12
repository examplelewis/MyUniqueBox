//
//  MUBResourceExHentaiTorrentsManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/10/02.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBResourceExHentaiTorrentsManager.h"
#import "MUBHTTPExHentaiManager.h"
#import <hpple/TFHpple.h>
#import "MUBResourceExHentaiHeader.h"

@interface MUBResourceExHentaiTorrentsManager ()

@property (copy) NSArray *URLs;

@property (assign) NSInteger download;
@property (strong) NSMutableArray<MUBResourceExHentaiTorrentModel *> *torrentModels;
@property (strong) NSMutableArray *failures;
@property (strong) NSMutableArray *noTorrents;

@end

@implementation MUBResourceExHentaiTorrentsManager

#pragma mark - Lifecycle
+ (instancetype)managerWithURLs:(NSArray *)URLs {
    MUBResourceExHentaiTorrentsManager *manager = [MUBResourceExHentaiTorrentsManager new];
    manager.URLs = URLs;
    return manager;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.download = 0;
        self.torrentModels = [NSMutableArray array];
        self.failures = [NSMutableArray array];
        self.noTorrents = [NSMutableArray array];
    }
    
    return self;
}

- (void)start {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"获取ExHentai种子信息, 流程开始"];
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"一共获取到 %ld 条地址", self.URLs.count];
    [[MUBUIManager defaultManager] resetProgressIndicatorMaxValue: (double)self.URLs.count];
    
    [self _fetchPostDetail];
}
- (void)_fetchPostDetail {
    for (NSInteger i = 0; i < self.URLs.count; i++) {
        [[MUBHTTPExHentaiManager defaultManager] getPostDetailWithPageURL:self.URLs[i] completionHandler:^(NSURLResponse * _Nonnull response, NSArray<MUBResourceExHentaiPageModel *> * _Nullable models, NSError * _Nullable error) {
            if (error) {
                [[MUBLogManager defaultManager] addErrorLogWithFormat:@"ExHentai 接口调用失败: %@", error.localizedDescription];
                [self.failures addObject:self.URLs[i]];
                [self.failures exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourceExHentaiFailureTorrentsFilePath]];
                [self _didFinishFetchPostDetail];
                
                return;
            }
            
            if (models.count == 0) {
                [[MUBLogManager defaultManager] addWarningLogWithFormat:@"接口未返回图包的信息, 跳过"];
                [self _didFinishFetchPostDetail];
                
                return;
            }
            
            MUBResourceExHentaiPageModel *model = models.firstObject;
            if (model.torrentcount == 0) {
                [[MUBLogManager defaultManager] addWarningLogWithFormat:@"接口未返回图包: %@ 的种子信息, 跳过", self.URLs[i]];
                [self _didFinishFetchPostDetail];
                
                return;
            }

            NSURL *uURL = [NSURL URLWithString:self.URLs[i]];
            NSString *torrentPageURL = [NSString stringWithFormat:@"%@://%@/gallerytorrents.php?gid=%ld&t=%@", uURL.scheme, uURL.host, model.gid, model.token];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:torrentPageURL]
                                                     cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                 timeoutInterval:60.0f];
            NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (error) {
                    [[MUBLogManager defaultManager] addErrorLogWithFormat:@"获取网页原始数据失败，原因: %@", error.localizedDescription];
                    [self.failures addObject:self.URLs[i]];
                    [self.failures exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourceExHentaiFailureTorrentsFilePath]];
                } else {
                    NSString *trackerID;
                    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
                    NSArray *aArray = [xpathParser searchWithXPathQuery:@"//span"];
                    for (TFHppleElement *element in aArray) {
                        if (![element.raw containsString:@"ehtracker.org"]) {
                            continue;
                        }
                        if (element.children.count == 0) {
                            continue;
                        }
                        
                        TFHppleElement *childElement = (TFHppleElement *)element.children.firstObject;
                        NSArray *contentComps = [childElement.content componentsSeparatedByString:@"/"];
                        trackerID = contentComps[contentComps.count - 2];
                    }
                    
                    if (!trackerID.isNotEmpty) {
                        [[MUBLogManager defaultManager] addErrorLogWithFormat:@"未获取到 %@ 的 trackerID", self.URLs[i]];
                        [self.failures addObject:self.URLs[i]];
                        [self.failures exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourceExHentaiFailureTorrentsFilePath]];
                    } else {
                        NSArray<MUBResourceExHentaiTorrentModel *> *torrentModels = [model.torrents sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"added" ascending:YES]]];
                        MUBResourceExHentaiTorrentModel *torrentModel = torrentModels.lastObject;
                        
                        // 1、如果种子的添加时间比当前Gallery的创建时间早，那就说明该种子对应的是之前版本的Gallery，就忽略掉
                        // 2、漫画和同人本不需要判断时间
                        BOOL isNotMangaOrDoujinshi = ![model.category isEqualToString:@"Doujinshi"] && ![model.category isEqualToString:@"Manga"];
                        if (torrentModel.added < model.posted && isNotMangaOrDoujinshi) {
                            [[MUBLogManager defaultManager] addWarningLogWithFormat:@"%@ 没有适用于当前版本Gallery的种子信息，跳过", self.URLs[i]];
                            [self.noTorrents addObject:self.URLs[i]];
                            [self.noTorrents exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourceExHentaiNoTorrentsFilePath]];
                        } else {
                            NSURL *pageURL = [NSURL URLWithString:self.URLs[i]];
                            torrentModel.URL = [NSString stringWithFormat:@"%@://%@/torrent/%@/%@.torrent", pageURL.scheme, pageURL.host, trackerID, torrentModel.tHash];
                            [self.torrentModels addObject:torrentModel];
                            [[self.torrentModels valueForKey:@"URL"] exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourceExHentaiSuccessTorrentsFilePath]];
                        }
                    }
                }
                
                [self _didFinishFetchPostDetail];
            }];
            
            [task resume];
        }];
    }
}

- (void)_didFinishFetchPostDetail {
    self.download += 1;
    [[MUBUIManager defaultManager] updateProgressIndicatorDoubleValue:(double)self.download];
    if (self.download != self.URLs.count) {
        return;
    }
    
    if (self.torrentModels.count == 0) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"没有获取到图包的种子信息"];
        return;
    }
    
    if (self.failures.count > 0) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"有%ld个页面无法解析，已导出到下载文件夹的 MUBResourceExHentaiFailureTorrents.txt 文件中", self.failures.count];
    }
    if (self.noTorrents.count > 0) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"有%ld个页面没有种子文件，已导出到下载文件夹的 MUBResourceExHentaiNoTorrents.txt 文件中", self.noTorrents.count];
    }
    
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"已获取到%lu条种子信息", self.torrentModels.count];
    
    if ([self.delegate respondsToSelector:@selector(manager:didGetAllTorrentURLs:renameInfo:error:)]) {
        NSMutableDictionary *renameInfo = [NSMutableDictionary dictionary];
        NSMutableArray *torrentURLs = [NSMutableArray array];
        for (MUBResourceExHentaiTorrentModel *model in self.torrentModels) {
            [torrentURLs addObject:model.URL];
            [renameInfo setValue:[NSString stringWithFormat:@"%@.torrent", model.name] forKey:model.URL];
        }
        
        [self.delegate manager:self didGetAllTorrentURLs:torrentURLs.copy renameInfo:renameInfo.copy error:nil];
    }
}

@end
