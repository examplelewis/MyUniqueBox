//
//  MUBResourceWeiboFavouriteLess9ImagesManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/11/02.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBResourceWeiboFavouriteLess9ImagesManager.h"
#import "MUBHTTPWeiboManager.h"
#import "MUBSQLiteManager.h"
#import "MUBResourceWeiboHeader.h"

@interface MUBResourceWeiboFavouriteLess9ImagesManager ()

@property (strong) NSMutableArray *lessWeiboIDs;
@property (assign) NSInteger fetchedPage;
@property (assign) NSInteger fetchedCount;

@end

@implementation MUBResourceWeiboFavouriteLess9ImagesManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.lessWeiboIDs = [NSMutableArray array];
        
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
            
            MUBResourceWeiboStatusModel *status = model.status.retweetedStatus ?: model.status;
            if (status.imgUrls.count > 0 && status.imgUrls.count < 9) {
                [self.lessWeiboIDs addObject:status.idstr];
            }
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
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"一共抓取到 %ld 条微博，一共有 %ld 条少于9张图片的微博", self.fetchedCount, self.lessWeiboIDs.count];
    
    if (self.lessWeiboIDs.count != 0) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"少于9张图片的微博ID如下:\n%@", self.lessWeiboIDs.stringValue];
    }
}

@end
