//
//  MUBSQLiteManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/29.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUBResourceWeiboModels.h"

NS_ASSUME_NONNULL_BEGIN

@interface MUBSQLiteManager : NSObject

#pragma mark - Lifecycle
+ (instancetype)defaultManager;

#pragma mark - Pixiv Block
// 获取拉黑的用户列表
// blockLevel: 0. 未判断; 1. 确定拉黑; 2. 不确定拉黑
- (NSArray *)getPixivUsersBlockStatusWithMemberIDs:(NSArray<NSString *> *)memberIDs blockLevel:(NSInteger)blockLevel;
// 获取不在拉黑表中的用户列表
- (NSArray *)getPixivUsersUnknownBlockStatusWithMemberIDs:(NSArray<NSString *> *)memberIDs;
// 更新确定拉黑的用户列表
- (void)updatePixivUsersBlock1StatusWithMemberIDs:(NSArray<NSString *> *)memberIDs;
// 更新不确定拉黑的用户列表
- (void)updatePixivUsersBlock2StatusWithMemberIDs:(NSArray<NSString *> *)memberIDs;

#pragma mark - WeiboStatus
- (BOOL)isWeiboStatusExistsWithStatusId:(NSString *)statusId;
- (void)insertWeiboStatuses:(NSArray<MUBResourceWeiboStatusModel *> *)models;

@end

NS_ASSUME_NONNULL_END
