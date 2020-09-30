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
    
}
+ (void)_checkBlockStatusWithMemberIDs:(NSArray<NSString *> *)memberIDs {
    
}
+ (void)_checkFetchStatusWithMemberIDs:(NSArray<NSString *> *)memberIDs {
    
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
            [result addObject:memberID];
        }
    }
    
    if (none.count > 0) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"有 %@ 条输入非Pixiv地址，跳过", none.count];
        [none exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourcePixivNonePixivMemberIDsExportFileName]];
    }
    
    return result.copy;
}

@end
