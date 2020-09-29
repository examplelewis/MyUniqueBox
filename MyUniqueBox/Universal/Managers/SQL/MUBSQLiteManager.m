//
//  MUBSQLiteManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/29.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBSQLiteManager.h"
#import <fmdb/FMDB.h>

#import "MUBSQLiteHeader.h"

@interface MUBSQLiteManager ()

@property (strong) FMDatabaseQueue *queue;

@end

@implementation MUBSQLiteManager

#pragma mark - Lifecycle
+ (instancetype)defaultManager {
    static MUBSQLiteManager *defaultManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [[self alloc] init];
        defaultManager.queue = [FMDatabaseQueue databaseQueueWithPath:[[MUBSettingManager defaultManager] pathOfContentInMainFolder:MUBSQLiteFileName]];
    });
    
    return defaultManager;
}

#pragma mark - WeiboStatus
- (BOOL)isWeiboStatusExistsWithStatusId:(NSString *)statusId {
    NSMutableArray *result = [NSMutableArray array];
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *rs = [db executeQuery:@"select * from weiboStatus where weibo_id = ?", statusId];
        while ([rs next]) {
            [result addObject:[rs stringForColumn:@"weibo_id"]];
        }
        
        [rs close];
    }];
    
    return result.count != 0;
}
- (void)insertWeiboStatuses:(NSArray<MUBResourceWeiboStatusModel *> *)models {
    for (MUBResourceWeiboStatusModel *model in models) {
        [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
            NSString *update = @"INSERT INTO weiboStatus (id, weibo_id, author_id, author_name, text, publish_time, fetch_time) values(?, ?, ?, ?, ?, ?, ?)";
            NSArray *arguments = @[[NSNull null], model.idstr, model.user.idstr, model.user.screenName, model.text, model.createdAtSqliteStr, [[NSDate date] formattedDateWithFormat:MUBTimeFormatyMdHms]];
            
            BOOL success = [db executeUpdate:update withArgumentsInArray:arguments];
            if (!success) {
                [[MUBLogManager defaultManager] addErrorLogWithFormat:@"往数据表:weiboStatus中插入数据时发生错误：%@", [db lastErrorMessage]];
                [[MUBLogManager defaultManager] addErrorLogWithFormat:@"插入的数据：%@", model];
            }
        }];
        
        for (NSString *imgURL in model.imgUrls) {
            [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
                NSString *update = @"INSERT INTO weiboImage (id, weibo_id, image_url) values(?, ?, ?)";
                NSArray *arguments = @[[NSNull null], model.idstr, imgURL];
                
                BOOL success = [db executeUpdate:update withArgumentsInArray:arguments];
                if (!success) {
                    [[MUBLogManager defaultManager] addErrorLogWithFormat:@"往数据表:weiboImage中插入数据时发生错误：%@", [db lastErrorMessage]];
                    [[MUBLogManager defaultManager] addErrorLogWithFormat:@"插入的数据：%@", imgURL];
                }
            }];
        }
    }
    
}

//#pragma mark - WeiboFetchedUser
///**
// * @brief 将已筛选的微博用户存入数据库
// * @param status 0: 未关注，未筛选，未拉黑; 1: 已筛选/已下载; 2: 已关注; 3: 已拉黑
// */
//- (void)insertWeiboFetchedUserIntoDatabase:(NSArray *)weiboUsers status:(NSInteger)status {
//    //先判断数据库是否存在，如果不存在，创建数据库
//    if (!db) {
//        [self createDatabase];
//    }
//    //判断数据库是否已经打开，如果没有打开，提示失败
//    if (![db open]) {
//        [[MRBLogManager defaultManager] showLogWithFormat:@"往数据表:weiboUsers中插入数据时发生错误：%@", [db lastErrorMessage]];
//        
//        return;
//    }
//    
//    [db beginTransaction];
//    
//    BOOL isRollBack = NO;
//    
//    @try {
//        for (NSInteger i = 0; i < weiboUsers.count; i++) {
//            NSDictionary *weiboUser = weiboUsers[i];
//            
//            BOOL weiboUserSuccess = [db executeUpdate:@"INSERT INTO weiboUsers (id, screen_name, user_url, add_time, status) values(?, ?, ?, ?, ?)", NULL, weiboUser[@"screenName"], weiboUser[@"userUrl"], [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss"], @(status)];
//            if (!weiboUserSuccess) {
//                [[MRBLogManager defaultManager] showLogWithFormat:@"往数据表:weiboUsers中插入数据时发生错误：%@", [db lastErrorMessage]];
//                [[MRBLogManager defaultManager] showLogWithFormat:@"数据：%@", weiboUser];
//            }
//        }
//    } @catch (NSException *exception) {
//        isRollBack = YES;
//        [db rollback];
//    } @finally {
//        if (!isRollBack) {
//            [db commit];
//        }
//    }
//    
//    [db close];
//}
//- (void)updateFetchedUserStatus:(NSArray *)weiboUserScreenNames status:(NSInteger)status {
//    //先判断数据库是否存在，如果不存在，创建数据库
//    if (!db) {
//        [self createDatabase];
//    }
//    //判断数据库是否已经打开，如果没有打开，提示失败
//    if (![db open]) {
//        [[MRBLogManager defaultManager] showLogWithFormat:@"往数据表:weiboUsers中插入数据时发生错误：%@", [db lastErrorMessage]];
//        
//        return;
//    }
//    
//    [db beginTransaction];
//    
//    BOOL isRollBack = NO;
//    
//    @try {
//        for (NSInteger i = 0; i < weiboUserScreenNames.count; i++) {
//            NSString *weiboUserScreenName = weiboUserScreenNames[i];
//            
//            NSString *sqliteStr = [NSString stringWithFormat:@"UPDATE weiboUsers SET status = %ld WHERE screen_name = %@", status, weiboUserScreenName];
//            BOOL weiboUserSuccess = [db executeUpdate:sqliteStr];
//            if (!weiboUserSuccess) {
//                [[MRBLogManager defaultManager] showLogWithFormat:@"往数据表:weiboUsers中插入数据时发生错误：%@", [db lastErrorMessage]];
//                [[MRBLogManager defaultManager] showLogWithFormat:@"数据：%@", weiboUserScreenName];
//            }
//        }
//    } @catch (NSException *exception) {
//        isRollBack = YES;
//        [db rollback];
//    } @finally {
//        if (!isRollBack) {
//            [db commit];
//        }
//    }
//    
//    [db close];
//}
//
//#pragma mark - WeiboRecommendArtists
//- (void)insertSingleWeiboRecommendArtistWithWeiboStatus:(MRBWeiboStatusRecommendArtisModel *)model {
//    //先判断数据库是否存在，如果不存在，创建数据库
//    if (!db) {
//        [self createDatabase];
//    }
//    //判断数据库是否已经打开，如果没有打开，提示失败
//    if (![db open]) {
//        [[MRBLogManager defaultManager] showLogWithFormat:@"往数据表:weiboRecommendArtists中插入数据时发生错误：%@", [db lastErrorMessage]];
//        
//        return;
//    }
//    
//    [db beginTransaction];
//    
//    BOOL isRollBack = NO;
//    
//    @try {
//        for (NSInteger i = 0; i < model.recommendSites.count; i++) {
//            NSDictionary *site = model.recommendSites[i];
//            
//            NSString *url = @"";
//            if ([site.allKeys[0] isEqualToString:@"twitter"]) {
//                url = [NSString stringWithFormat:@"https://twitter.com/%@", site.allValues[0]];
//            }
//            
//            BOOL success = [db executeUpdate:@"INSERT INTO weiboRecommendArtists (id, weiboUserId, weiboUser, weiboStatus, recommendSite, recommendAccount, recommendUrl, recordTime) values(?, ?, ?, ?, ?, ?, ?, ?)", NULL, model.user_id_str, model.user_screen_name, model.text, site.allKeys[0], site.allValues[0], url, [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss"]];
//            if (!success) {
//                [[MRBLogManager defaultManager] showLogWithFormat:@"往数据表:weiboRecommendArtists中插入数据时发生错误：%@", [db lastErrorMessage]];
//                [[MRBLogManager defaultManager] showLogWithFormat:@"数据：%@", model];
//            }
//        }
//    } @catch (NSException *exception) {
//        isRollBack = YES;
//        [db rollback];
//    } @finally {
//        if (!isRollBack) {
//            [db commit];
//        }
//    }
//    
//    [db close];
//}
//- (BOOL)isExistingWeiboRecommendArtist:(MRBWeiboStatusRecommendArtisModel *)model {
//    //先判断数据库是否存在，如果不存在，创建数据库
//    if (!db) {
//        [self createDatabase];
//    }
//    //判断数据库是否已经打开，如果没有打开，提示失败
//    if (![db open]) {
//        [[MRBLogManager defaultManager] showLogWithFormat:@"从数据表:weiboRecommendArtists中查询数据时发生错误：%@", [db lastErrorMessage]];
//        [[MRBLogManager defaultManager] showLogWithFormat:@"数据：%@", model];
//        
//        return NO;
//    }
//    //为数据库设置缓存，提高查询效率
//    [db setShouldCacheStatements:YES];
//    
//    NSInteger foundCount = 0;
//    for (NSInteger i = 0; i < model.recommendSites.count; i++) {
//        NSDictionary *site = model.recommendSites[i];
//        
//        if ([self foundByDifferentEncodingValue:site.allValues[0]]) {
//            foundCount = 1;
//            break;
//        }
//        
//        FMResultSet *rs = [db executeQuery:@"select * from weiboRecommendArtists where recommendSite = ? COLLATE NOCASE and recommendAccount = ? COLLATE NOCASE", site.allKeys[0], site.allValues[0]];
//        while ([rs next]) {
//            foundCount += 1;
//        }
//        [rs close];
//    }
//    
//    [db close];
//    
//    return foundCount != 0;
//}
//
//- (BOOL)foundByDifferentEncodingValue:(NSString *)value {
//    NSArray *values = @[@"limesaurus"];
//    BOOL found = NO;
//    
//    for (NSInteger i = 0; i < values.count; i++) {
//        // 因为编码不同，导致可能输出的字符是一样的，但是单纯的进行 isEqualToString: 比较会返回NO
//        if ([[value stringByRemovingPercentEncoding] isEqualToString:[values[i] stringByRemovingPercentEncoding]]) {
//            found = YES;
//            break;
//        }
//    }
//    
//    return found;
//}

@end
