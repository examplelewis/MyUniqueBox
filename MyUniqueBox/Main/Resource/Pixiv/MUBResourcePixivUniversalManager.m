//
//  MUBResourcePixivUniversalManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/10/01.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBResourcePixivUniversalManager.h"
#import "MUBResourcePixivHeader.h"
#import "MUBSQLiteManager.h"

@implementation MUBResourcePixivUniversalManager

+ (void)getMemberIDsWithType:(MUBResourcePixivUniversalType)type {
    NSString *memberIDStr = [MUBUIManager defaultManager].viewController.inputTextView.string;
    if (!memberIDStr.isNotEmpty) {
        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"没有获得任何数据，请检查输入框"];
        return;
    }
    
    NSArray *memberIDs = [memberIDStr componentsSeparatedByString:@"\n"];
    memberIDs = [MUBResourcePixivUniversalManager filterNonePixivMemberIDs:memberIDs];
    
    [MUBResourcePixivUniversalManager _getMemberIDsWithType:type memberIDs:memberIDs];
}
+ (void)_getMemberIDsWithType:(MUBResourcePixivUniversalType)type memberIDs:(NSArray<NSString *> *)memberIDs {
    switch (type) {
        case MUBResourcePixivUniversalTypeUpdateBlock1: {
            [[MUBSQLiteManager defaultManager] updatePixivUsersBlock1StatusWithMemberIDs:memberIDs];
        }
            break;
        case MUBResourcePixivUniversalTypeUpdateBlock2: {
            [[MUBSQLiteManager defaultManager] updatePixivUsersBlock2StatusWithMemberIDs:memberIDs];
        }
            break;
        case MUBResourcePixivUniversalTypeFollowStatus: {
            [MUBResourcePixivUniversalManager _checkFollowStatusWithMemberIDs:memberIDs];
        }
            break;
        case MUBResourcePixivUniversalTypeBlockStatus: {
            [MUBResourcePixivUniversalManager _checkBlockStatusWithMemberIDs:memberIDs];
        }
            break;
        case MUBResourcePixivUniversalTypeFetchStatus: {
            [MUBResourcePixivUniversalManager _checkFetchStatusWithMemberIDs:memberIDs];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Status
+ (void)_checkFollowStatusWithMemberIDs:(NSArray<NSString *> *)memberIDs {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"查询多个用户的关注状态, 流程开始"];
    
    NSArray *follows = [[MUBSQLiteManager defaultManager] getPixivUsersFollowStatusWithMemberIDs:memberIDs isFollow:YES];
    follows = [MUBResourcePixivUniversalManager fullPixivURLsWithMemberIDs:follows];
    [follows exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourcePixivFollowUserURLsExportFileName] behavior:MUBFileOpertaionBehaviorShowSuccessLog];
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"共找到 %@ 个关注的用户", follows.count];
    
    NSArray *notFollows = [[MUBSQLiteManager defaultManager] getPixivUsersFollowStatusWithMemberIDs:memberIDs isFollow:NO];
    notFollows = [MUBResourcePixivUniversalManager fullPixivURLsWithMemberIDs:notFollows];
    [notFollows exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourcePixivFollowNotUserURLsExportFileName] behavior:MUBFileOpertaionBehaviorShowSuccessLog];
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"共找到 %@ 个未关注的用户", notFollows.count];
    
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"查询多个用户的关注状态, 流程开始"];
}
+ (void)_checkBlockStatusWithMemberIDs:(NSArray<NSString *> *)memberIDs {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"查询多个用户的拉黑状态, 流程开始"];
    
    NSArray *block1s = [[MUBSQLiteManager defaultManager] getPixivUsersBlockStatusWithMemberIDs:memberIDs blockLevel:1 isEqual:YES];
    block1s = [MUBResourcePixivUniversalManager fullPixivURLsWithMemberIDs:block1s];
    [block1s exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourcePixivBlock1UserURLsExportFileName] behavior:MUBFileOpertaionBehaviorShowSuccessLog];
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"共找到 %@ 个确定拉黑的用户", block1s.count];
    
    NSArray *blockNot1s = [[MUBSQLiteManager defaultManager] getPixivUsersBlockStatusWithMemberIDs:memberIDs blockLevel:1 isEqual:NO];
    blockNot1s = [MUBResourcePixivUniversalManager fullPixivURLsWithMemberIDs:blockNot1s];
    [blockNot1s exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourcePixivBlockNot1UserURLsExportFileName] behavior:MUBFileOpertaionBehaviorShowSuccessLog];
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"共找到 %@ 个未确定拉黑的用户", blockNot1s.count];
    
    NSArray *blockUnknowns = [[MUBSQLiteManager defaultManager] getPixivUsersUnknownBlockStatusWithMemberIDs:memberIDs];
    blockUnknowns = [MUBResourcePixivUniversalManager fullPixivURLsWithMemberIDs:blockUnknowns];
    [blockUnknowns exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourcePixivBlockUnknownUserURLsExportFileName] behavior:MUBFileOpertaionBehaviorShowSuccessLog];
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"共找到 %@ 个未拉黑的用户", blockUnknowns.count];
    
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"查询多个用户的拉黑状态, 流程结束"];
}
+ (void)_checkFetchStatusWithMemberIDs:(NSArray<NSString *> *)memberIDs {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"查询多个用户的抓取状态, 流程开始"];
    
    NSArray *fetches = [[MUBSQLiteManager defaultManager] getPixivUsersFetchStatusWithMemberIDs:memberIDs isFetch:YES];
    fetches = [MUBResourcePixivUniversalManager fullPixivURLsWithMemberIDs:fetches];
    [fetches exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourcePixivFetchUserURLsExportFileName] behavior:MUBFileOpertaionBehaviorShowSuccessLog];
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"共找到 %@ 个抓取的用户", fetches.count];
    
    NSArray *notFetches = [[MUBSQLiteManager defaultManager] getPixivUsersFetchStatusWithMemberIDs:memberIDs isFetch:NO];
    notFetches = [MUBResourcePixivUniversalManager fullPixivURLsWithMemberIDs:notFetches];
    [notFetches exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourcePixivFetchNotUserURLsExportFileName] behavior:MUBFileOpertaionBehaviorShowSuccessLog];
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"共找到 %@ 个未抓取的用户", notFetches.count];
    
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"查询多个用户的抓取状态, 流程开始"];
}

#pragma mark - Tools
+ (NSArray<NSString *> *)filterNonePixivMemberIDs:(NSArray<NSString *> *)memberIDs {
    NSMutableArray *result = [NSMutableArray array];
    NSMutableArray *none = [NSMutableArray array];
    
    NSCharacterSet *numberSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    for (NSString *memberID in memberIDs) {
        NSScanner *scanner = [NSScanner scannerWithString:memberID];
        [scanner scanUpToCharactersFromSet:numberSet intoString:NULL];
        NSString *numberString;
        [scanner scanCharactersFromSet:numberSet intoString:&numberString];
        
        if ([numberString integerValue] == 0) {
            [none addObject:memberID];
        } else {
            [result addObject:numberString];
        }
    }
    
    if (none.count > 0) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"有 %@ 条输入非Pixiv地址，跳过", none.count];
        [none exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourcePixivNonePixivMemberIDsExportFileName] behavior:MUBFileOpertaionBehaviorShowSuccessLog];
    }
    
    return result.copy;
}
+ (NSArray *)fullPixivURLsWithMemberIDs:(NSArray *)memberIDs {
    return [memberIDs bk_map:^id(NSString *obj) {
        return [MUBResourcePixivUniversalManager fullPixivURLWithMemberID:obj];
    }];
}
+ (NSString *)fullPixivURLWithMemberID:(NSString *)memberID {
    return [NSString stringWithFormat:@"https://www.pixiv.net/member_illust.php?id=%@", memberID];
}

@end
