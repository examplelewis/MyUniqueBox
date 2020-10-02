//
//  MUBResourceWeiboBoundaryManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/30.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBResourceWeiboBoundaryManager.h"
#import "MUBHTTPWeiboManager.h"
@implementation MUBResourceWeiboBoundaryManager

+ (void)markNewestFavorAsBoundary {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"原有边界微博的ID：%@", [MUBSettingManager defaultManager].weiboBoundaryModel._id];
    
    [[MUBHTTPWeiboManager defaultManager] getWeiboFavoritesWithPage:1 completionHandler:^(NSURLResponse * _Nonnull response, NSArray<MUBResourceWeiboFavouriteModel *> * _Nullable models, NSError * _Nullable error) {
        if (error) {
            [MUBAlertManager showCriticalAlertOnMainWindowWithMessage:@"调用微博收藏列表接口" info:error.localizedDescription runModal:NO handler:nil];
            return;
        }
        
        if (models.count == 0) {
            [[MUBLogManager defaultManager] addWarningLogWithFormat:@"当前没有收藏内容，跳过"];
            return;
        }
        
        MUBResourceWeiboFavouriteModel *model = models.firstObject;
        [MUBSettingManager defaultManager].weiboBoundaryModel.author = model.status.user.screenName;
        [MUBSettingManager defaultManager].weiboBoundaryModel._id = [NSString stringWithFormat:@"%ld", model.status._id];
        [MUBSettingManager defaultManager].weiboBoundaryModel.text = model.status.text;
        [[MUBSettingManager defaultManager] updateWeiboBoundaryModel];
        
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"已经找到边界微博的ID：%@", model.status.idstr];
    }];
}

@end
