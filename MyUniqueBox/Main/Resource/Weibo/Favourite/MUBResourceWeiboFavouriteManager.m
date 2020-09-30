//
//  MUBResourceWeiboFavouriteManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/28.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBResourceWeiboFavouriteManager.h"
#import "MUBHTTPWeiboManager.h"
#import "MUBSQLiteManager.h"
#import "MUBSQLiteSettingManager.h"
#import "MUBResourceWeiboHeader.h"

@interface MUBResourceWeiboFavouriteManager ()

@property (strong) NSMutableDictionary *statuses;
@property (strong) NSMutableArray<NSString *> *images;
@property (strong) NSMutableArray<MUBResourceWeiboStatusModel *> *models;
@property (strong) NSMutableArray<NSString *> *ids; // 记录当前抓取到的 weibo，用于去重

@property (assign) NSInteger fetchedPage;
@property (assign) NSInteger fetchedCount;

@end

@implementation MUBResourceWeiboFavouriteManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.statuses = [NSMutableDictionary dictionary];
        self.images = [NSMutableArray array];
        self.models = [NSMutableArray array];
        self.ids = [NSMutableArray array];
        
        self.fetchedPage = 1;
        self.fetchedCount = 0;
        
        self.maxFetchCount = 99999;
    }
    return self;
}

- (void)start {
    [self _fetchAPI];
}
- (void)_fetchAPI {
    [[MUBHTTPWeiboManager defaultManager] getWeiboFavoritesWithPage:self.fetchedPage completionHandler:^(NSURLResponse * _Nonnull response, NSArray<MUBResourceWeiboFavouriteModel *> * _Nullable models, NSError * _Nullable error) {
        if (error) {
            [MUBAlertManager showCriticalAlertOnMainWindowWithMessage:@"调用微博收藏列表接口" info:error.localizedDescription runModal:NO handler:nil];
            return;
        }
        
        BOOL found = NO;
        for (NSInteger i = 0; i < models.count; i++) {
            MUBResourceWeiboFavouriteModel *model = models[i];
            
            if ([model.status.idstr isEqualToString:[MUBSettingManager defaultManager].weiboBoundaryModel._id]) {
                found = YES;
                break;
            }
            
            self.fetchedCount += 1;
            if (self.fetchedCount > self.maxFetchCount) {
                break;
            }
            
            MUBResourceWeiboStatusModel *status = model.status.retweetedStatus ?: model.status;
            // 如果在当前抓取的流程中出现了重复的 id，那么跳过
            if ([self.ids containsObject:status.idstr]) {
                continue;
            }
            // 如果当前微博在数据库中有记录，那么跳过
            if ([[MUBSQLiteManager defaultManager] isWeiboStatusExistsWithStatusId:status.idstr]) {
                continue;
            }
            
            [self.ids addObject:status.idstr];
            [self.models addObject:status];
            NSString *statusKey = [self _weiboStatusFolderNameFromModel:status];
            [self.statuses setObject:status.imgUrls forKey:statusKey];
            [self.images addObjectsFromArray:status.imgUrls];
        }

        // 如果找到了边界微博，或者一直没有找到，直到取到的微博数量小于50，代表着没有更多收藏微博了，即边界微博出错
        if (found || models.count < MUBResourceWeiboFavoriteAPIFetchCount || self.fetchedCount > self.maxFetchCount) {
            [self _exportResult];
        } else {
            self.fetchedPage += 1; // 计数
            [self _fetchAPI];
        }
    }];
}
- (NSString *)_weiboStatusFolderNameFromModel:(MUBResourceWeiboStatusModel *)model {
    // 1、先添加用户昵称
    NSString *statusKey = [NSString stringWithFormat:@"%@+", model.user.screenName];

    // 2、添加标签以及文字
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#[^#]+#" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *results = [regex matchesInString:model.text options:0 range:NSMakeRange(0, model.text.length)];
    if (error) {
        [[MUBLogManager defaultManager] addErrorLogWithFormat:@"正则解析微博文字中的标签出错，原因：%@", error.localizedDescription];
    }
    if (results.count == 0) {
        // 2.1、没有标签的话，截取前100个文字
        if (model.text.length <= 100) {
            statusKey = [statusKey stringByAppendingFormat:@"[无标签]+%@+", model.text];
        } else {
            statusKey = [statusKey stringByAppendingFormat:@"[无标签]+%@+", [model.text substringToIndex:100]];
        }
    } else {
        // 2.2.1、有标签的话，先添加所有标签
        for (NSInteger i = 0; i < results.count; i++) {
            NSTextCheckingResult *result = results[i];
            NSString *hashtag = [model.text substringWithRange:result.range];
            hashtag = [hashtag stringByReplacingOccurrencesOfString:@"#" withString:@""];
            statusKey = [statusKey stringByAppendingFormat:@"%@+", hashtag];
        }

        // 2.2.2、再添加前60个文字
        NSString *noTagText = model.text;
        for (NSInteger i = results.count - 1; i >= 0; i--) {
            NSTextCheckingResult *result = results[i];
            noTagText = [noTagText stringByReplacingCharactersInRange:result.range withString:@""];
        }
        if (noTagText.length <= 60) {
            statusKey = [statusKey stringByAppendingFormat:@"%@+", noTagText];
        } else {
            statusKey = [statusKey stringByAppendingFormat:@"%@+", [noTagText substringToIndex:60]];
        }
    }

    // 3、添加微博发布时间
    statusKey = [statusKey stringByAppendingFormat:@"%@", model.createdAtReadableStr];

    // 4、防止有 / 出现以及其他特殊字符
    statusKey = [statusKey stringByReplacingOccurrencesOfString:@"/" withString:@" "];
    statusKey = [statusKey stringByReplacingOccurrencesOfString:@"\n" withString:@" "];

    return statusKey;
}

#pragma mark -- 辅助方法 --
- (void)_exportResult {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"一共抓取到 %ld 条微博，去重后剩余 %ld 条，重复 %ld 条", self.fetchedCount, self.statuses.count, self.fetchedCount - self.statuses.count];
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"流程已经完成，共有 %ld 条微博的 %ld 条图片地址被获取到", self.statuses.count, self.images.count];

    if (self.images.count == 0) {
        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"未发现可下载的资源"];
        return;
    }
    
    [[MUBLogManager defaultManager] saveDefaultLocalLog:self.images.stringValue];

    // 使用NSOrderedSet进行一次去重的操作
    NSOrderedSet *set = [NSOrderedSet orderedSetWithArray:self.images];
    self.images = [NSMutableArray arrayWithArray:set.array];
    [self.images exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourceWeiboImageURLsFilePath]];
    [self.statuses exportToPlistPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourceWeiboStatusFilePath]];

    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"将获取到微博信息存储到数据库中"];
    dispatch_async(dispatch_get_main_queue(), ^{
        // 往数据库里写入的时候，要按照获取的倒序，也就是最早收藏的微博排在最前
        NSArray *reversedModels = [[self.models reverseObjectEnumerator] allObjects];
        [[MUBSQLiteManager defaultManager] insertWeiboStatuses:reversedModels];
        [MUBSQLiteSettingManager backupDatabase];
    });

    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"1秒后开始下载图片"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self _startDownload];
    });
}
- (void)_startDownload {
    MUBDownloadSettingModel *model = [MUBDownloadSettingManager defaultManager].defaultPrefModel;
    model.downloadFolderPath = [[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:@"微博"];
    
    MUBDownloadManager *manager = [MUBDownloadManager managerWithSettingModel:model URLs:self.images downloadFilePath:nil];
    manager.onFinish = ^{
        [MUBFileManager trashFilePath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourceWeiboImageURLsFilePath]];
//        OrganizeManager *manager = [[OrganizeManager alloc] initWithPlistPath:weiboStatusPlistFilePath];
//        [manager startOrganizing];
    };
    [manager start];
}

@end
