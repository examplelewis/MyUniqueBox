//
//  MUBHTTPWeiboManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/28.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBHTTPManager.h"
#import "MUBResourceWeiboModels.h"

NS_ASSUME_NONNULL_BEGIN

@interface MUBHTTPWeiboManager : MUBHTTPManager

#pragma mark - Lifecycle
+ (instancetype)defaultManager;

#pragma mark - Weibo
- (void)getWeiboTokenWithSuccess:(void(^)(NSDictionary *dic))success failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed;
- (void)getWeiboTokenInfoWithSuccess:(void(^)(NSDictionary *dic))success failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed;
- (void)getWeiboLimitInfoWithSuccess:(void(^)(NSDictionary *dic))success failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed;

- (void)getWeiboFavoritesWithPage:(NSInteger)page completionHandler:(nonnull void (^)(NSURLResponse * _Nonnull response, NSArray<MUBResourceWeiboFavouriteModel *> * _Nullable models, NSError * _Nullable error))completionHandler;
- (void)unfavoriteWeiboWithStatusId:(NSString *)statusId completionHandler:(nonnull void (^)(NSURLResponse * _Nonnull response, NSDictionary * _Nullable object, NSError * _Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
