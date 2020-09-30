//
//  MUBResourceWeiboFaviouriteDuplicateManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/30.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBResourceWeiboFaviouriteDuplicateManager.h"
#import "MUBHTTPWeiboManager.h"
#import "MUBSQLiteManager.h"
#import "MUBResourceWeiboHeader.h"

@interface MUBResourceWeiboFaviouriteDuplicateManager ()

@property (strong) NSMutableArray *compareWeiboIds; // 没有重复的微博IDs，这里面如果没有转发的微博是原微博的ID，有转发微博时转发微博的ID
@property (strong) NSMutableArray *duplicateWeiboIds; // 有重复的微博IDs，这里面全部都是当前微博的ID
@property (assign) NSInteger fetchedPage;
@property (assign) NSInteger fetchedCount;

@end

@implementation MUBResourceWeiboFaviouriteDuplicateManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.compareWeiboIds = [NSMutableArray array];
        self.duplicateWeiboIds = [NSMutableArray array];
        
        self.fetchedPage = 1;
        self.fetchedCount = 0;
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
            
            MUBResourceWeiboStatusModel *status = model.status;
            MUBResourceWeiboStatusModel *compare = model.status.retweetedStatus ?: model.status;
            // 如果在当前抓取的流程中出现了重复的 id，那么跳过
            if ([self.compareWeiboIds containsObject:compare.idstr]) {
                [self.duplicateWeiboIds addObject:status.idstr];
                
                continue;
            }
            // 如果当前微博在数据库中有记录，那么跳过
            if ([[MUBSQLiteManager defaultManager] isWeiboStatusExistsWithStatusId:compare.idstr]) {
                [self.duplicateWeiboIds addObject:status.idstr];
                
                continue;
            }
            
            [self.compareWeiboIds addObject:compare.idstr];
        }

        // 如果找到了边界微博，或者一直没有找到，直到取到的微博数量小于50，代表着没有更多收藏微博了，即边界微博出错
        if (found || models.count < MUBResourceWeiboFavoriteAPIFetchCount) {
            [self _exportResult];
        } else {
            self.fetchedPage += 1; // 计数
            [self _fetchAPI];
        }
    }];
}

- (void)_exportResult {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"一共抓取到 %ld 条微博，未重复 %ld 条，重复 %ld 条", self.fetchedCount, self.compareWeiboIds.count, self.duplicateWeiboIds.count];
    
    if (self.duplicateWeiboIds.count == 0) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"没有重复的ID"];
    } else {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"重复的ID如下:\n%@", self.duplicateWeiboIds.stringValue];
    }
}

+ (void)unfavouriteDuplicateWeibos {
    NSString *weiboIDStr;
    if ([MUBFileManager fileExistsAtPath:MUBResourceWeiboDuplicateIDsFilePath]) {
        weiboIDStr = [NSString stringWithContentsOfFile:MUBResourceWeiboDuplicateIDsFilePath encoding:NSUTF8StringEncoding error:nil];
    } else {
        weiboIDStr = [MUBUIManager defaultManager].viewController.inputTextView.string;
    }
    if (!weiboIDStr.isNotEmpty) {
        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"没有获得任何数据，请检查输入框"];
        return;
    }
    
    NSArray *weiboIDs = [weiboIDStr componentsSeparatedByString:@"\n"];
    for (NSInteger i = 0; i < weiboIDs.count; i++) {
        NSString *weiboID = weiboIDs[i];
        
        [[MUBHTTPWeiboManager defaultManager] unfavoriteWeiboWithStatusId:weiboID completionHandler:^(NSURLResponse * _Nonnull response, NSDictionary * _Nullable object, NSError * _Nullable error) {
            if (error) {
                if ([object[@"error_code"] integerValue] == 20705) {
                    // 没收藏也算取消收藏成功
                    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"%@ 取消收藏成功", weiboID];
                } else {
                    [MUBAlertManager showCriticalAlertOnMainWindowWithMessage:@"调用微博收藏列表接口" info:error.localizedDescription runModal:NO handler:nil];
                }
                
                return;
            }
            
            MUBResourceWeiboFavouriteModel *model = [MUBResourceWeiboFavouriteModel yy_modelWithJSON:object];
            if (!model.status.favorited) {
                [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"%@ 取消收藏成功", weiboID];
            } else {
                [[MUBLogManager defaultManager] addWarningLogWithFormat:@"%@ 取消收藏失败: %@", weiboID, object[@"error"]];
            }
        }];
    }
}

@end
