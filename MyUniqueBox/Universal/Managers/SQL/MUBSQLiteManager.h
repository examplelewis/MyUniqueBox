//
//  MUBSQLiteManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/29.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUBResourceWeiboModels.h"
#import "MUBResourceExHentaiModels.h"

NS_ASSUME_NONNULL_BEGIN

@interface MUBSQLiteManager : NSObject

#pragma mark - Lifecycle
+ (instancetype)defaultManager;

#pragma mark - ExHentai
- (NSInteger)getDGIDWithExHentaiPageModel:(MUBResourceExHentaiPageModel *)model;
- (NSArray<MUBResourceExHentaiImageModel *> *)filteredExHentaiImageModelsFrom:(NSArray<MUBResourceExHentaiImageModel *> *)imageModels model:(MUBResourceExHentaiPageModel *)model;
- (void)insertExHentaiImageModels:(NSArray<MUBResourceExHentaiImageModel *> *)imageModels model:(MUBResourceExHentaiPageModel *)model downloadFolderPath:(NSString *)downloadFolderPath;

#pragma mark - Pixiv Follow
// 获取关注的用户列表
- (NSArray *)getPixivUsersFollowStatusWithMemberIDs:(NSArray<NSString *> *)memberIDs isFollow:(BOOL)isFollow;

#pragma mark - Pixiv Block
// 获取拉黑的用户列表
// blockLevel: 0. 未判断; 1. 确定拉黑; 2. 不确定拉黑
- (NSArray *)getPixivUsersBlockStatusWithMemberIDs:(NSArray<NSString *> *)memberIDs blockLevel:(NSInteger)blockLevel isEqual:(BOOL)isEqual;
// 获取不在拉黑表中的用户列表
- (NSArray *)getPixivUsersUnknownBlockStatusWithMemberIDs:(NSArray<NSString *> *)memberIDs;
// 更新确定拉黑的用户列表
- (void)updatePixivUsersBlock1StatusWithMemberIDs:(NSArray<NSString *> *)memberIDs;
// 更新不确定拉黑的用户列表
- (void)updatePixivUsersBlock2StatusWithMemberIDs:(NSArray<NSString *> *)memberIDs;

#pragma mark - Pixiv Fetch
// 获取抓取的用户列表
- (NSArray *)getPixivUsersFetchStatusWithMemberIDs:(NSArray<NSString *> *)memberIDs isFetch:(BOOL)isFetch;

#pragma mark - Pixiv Remove
// 删除PixivUtil数据库中的下载记录
- (void)removePixivUntilUsersDownloadRecordsWithMemberIDs:(NSArray<NSString *> *)memberIDs;

#pragma mark - Pixiv Follow & Block
// 获取关注和拉黑用户列表
- (NSArray *)getFollowAndBlockUsers;

#pragma mark - WeiboStatus
- (BOOL)isWeiboStatusExistsWithStatusId:(NSString *)statusId;
- (void)insertWeiboStatuses:(NSArray<MUBResourceWeiboStatusModel *> *)models;

@end

NS_ASSUME_NONNULL_END
