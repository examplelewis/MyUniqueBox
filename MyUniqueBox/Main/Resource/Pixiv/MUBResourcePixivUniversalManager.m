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

#pragma mark - getMemberIDs
+ (void)getInputsWithType:(MUBResourcePixivUniversalType)type {
    NSString *inputStr = [MUBUIManager defaultManager].viewController.inputTextView.string;
    if (!inputStr.isNotEmpty) {
        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"没有获得任何数据，请检查输入框"];
        return;
    }
    NSArray<NSString *> *inputs = [inputStr componentsSeparatedByString:@"\n"];
    
    NSArray<NSString *> *memberIDs = [MUBResourcePixivUniversalManager filterIllustURLsFromInputs:inputs];
    memberIDs = [MUBResourcePixivUniversalManager filterNoneNumberURLsFromInputs:memberIDs];
    memberIDs = [memberIDs bk_map:^id(NSString *obj) {
        return [MUBResourcePixivUniversalManager numberStringInInput:obj];
    }];
    memberIDs = [MUBResourcePixivUniversalManager filterDuplicateURLsFromInputs:memberIDs];
    
    [MUBResourcePixivUniversalManager getInputsWithType:type inputs:inputs memberIDs:memberIDs];
}
+ (void)getInputsWithType:(MUBResourcePixivUniversalType)type inputs:(NSArray<NSString *> *)inputs memberIDs:(NSArray<NSString *> *)memberIDs {
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
        case MUBResourcePixivUniversalTypeRemoveUsersDownloadRecords: {
            [[MUBSQLiteManager defaultManager] removePixivUntilUsersDownloadRecordsWithMemberIDs:memberIDs];
        }
            break;
        case MUBResourcePixivUniversalTypeExportFollowAndBlockUsers: {
            [MUBResourcePixivUniversalManager _exportFollowAndBlockUsersWithMemberIDs:memberIDs];
        }
            break;
        case MUBResourcePixivUniversalTypeShowUserState: {
            [MUBResourcePixivUniversalManager _showUserStateWithMemberIDs:memberIDs export:NO];
        }
            break;
        case MUBResourcePixivUniversalTypeExportUserState: {
            [MUBResourcePixivUniversalManager _showUserStateWithMemberIDs:memberIDs export:YES];
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
    follows = [MUBResourcePixivUniversalManager fullPixivMemberURLsWithMemberIDs:follows];
    [follows exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourcePixivFollowUserURLsExportFileName] behavior:MUBFileOpertaionBehaviorShowSuccessLog];
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"共找到 %@ 个关注的用户", follows.count];
    
    NSArray *notFollows = [[MUBSQLiteManager defaultManager] getPixivUsersFollowStatusWithMemberIDs:memberIDs isFollow:NO];
    notFollows = [MUBResourcePixivUniversalManager fullPixivMemberURLsWithMemberIDs:notFollows];
    [notFollows exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourcePixivFollowNotUserURLsExportFileName] behavior:MUBFileOpertaionBehaviorShowSuccessLog];
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"共找到 %@ 个未关注的用户", notFollows.count];
    
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"查询多个用户的关注状态, 流程开始"];
}
+ (void)_checkBlockStatusWithMemberIDs:(NSArray<NSString *> *)memberIDs {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"查询多个用户的拉黑状态, 流程开始"];
    
    NSArray *block1s = [[MUBSQLiteManager defaultManager] getPixivUsersBlockStatusWithMemberIDs:memberIDs blockLevel:1 isEqual:YES];
    block1s = [MUBResourcePixivUniversalManager fullPixivMemberURLsWithMemberIDs:block1s];
    [block1s exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourcePixivBlock1UserURLsExportFileName] behavior:MUBFileOpertaionBehaviorShowSuccessLog];
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"共找到 %@ 个确定拉黑的用户", block1s.count];
    
    NSArray *blockNot1s = [[MUBSQLiteManager defaultManager] getPixivUsersBlockStatusWithMemberIDs:memberIDs blockLevel:1 isEqual:NO];
    blockNot1s = [MUBResourcePixivUniversalManager fullPixivMemberURLsWithMemberIDs:blockNot1s];
    [blockNot1s exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourcePixivBlockNot1UserURLsExportFileName] behavior:MUBFileOpertaionBehaviorShowSuccessLog];
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"共找到 %@ 个未确定拉黑的用户", blockNot1s.count];
    
    NSArray *blockUnknowns = [[MUBSQLiteManager defaultManager] getPixivUsersUnknownBlockStatusWithMemberIDs:memberIDs];
    blockUnknowns = [MUBResourcePixivUniversalManager fullPixivMemberURLsWithMemberIDs:blockUnknowns];
    [blockUnknowns exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourcePixivBlockUnknownUserURLsExportFileName] behavior:MUBFileOpertaionBehaviorShowSuccessLog];
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"共找到 %@ 个未拉黑的用户", blockUnknowns.count];
    
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"查询多个用户的拉黑状态, 流程结束"];
}
+ (void)_checkFetchStatusWithMemberIDs:(NSArray<NSString *> *)memberIDs {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"查询多个用户的抓取状态, 流程开始"];
    
    NSArray *fetches = [[MUBSQLiteManager defaultManager] getPixivUsersFetchStatusWithMemberIDs:memberIDs isFetch:YES];
    fetches = [MUBResourcePixivUniversalManager fullPixivMemberURLsWithMemberIDs:fetches];
    [fetches exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourcePixivFetchUserURLsExportFileName] behavior:MUBFileOpertaionBehaviorShowSuccessLog];
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"共找到 %ld 个抓取的用户", fetches.count];
    
    NSArray *notFetches = [[MUBSQLiteManager defaultManager] getPixivUsersFetchStatusWithMemberIDs:memberIDs isFetch:NO];
    notFetches = [MUBResourcePixivUniversalManager fullPixivMemberURLsWithMemberIDs:notFetches];
    [notFetches exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourcePixivFetchNotUserURLsExportFileName] behavior:MUBFileOpertaionBehaviorShowSuccessLog];
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"共找到 %ld 个未抓取的用户", notFetches.count];
    
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"查询多个用户的抓取状态, 流程结束"];
}

#pragma mark - Follow & Export
+ (void)_exportFollowAndBlockUsersWithMemberIDs:(NSArray<NSString *> *)memberIDs {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"导出既关注又被拉黑的用户名单, 流程开始"];
    
    NSArray *duplicates = [[MUBSQLiteManager defaultManager] getFollowAndBlockUsers];
    if (duplicates.count == 0) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"导出既关注又被拉黑的用户名单，未发现重复用户，流程结束"];
    } else {
        [duplicates exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourcePixivFollowAndBlockUsersExportFileName]];
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"导出既关注又被拉黑的用户名单，发现 %ld 个重复用户，流程结束", duplicates.count];
    }
}

#pragma mark - User State
+ (void)_showUserStateWithMemberIDs:(NSArray<NSString *> *)memberIDs export:(BOOL)export {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"%@多个用户的状态, 流程开始", export ? @"导出" : @"查询"];
    
    NSArray *follows = [[MUBSQLiteManager defaultManager] getPixivUsersFollowStatusWithMemberIDs:memberIDs isFollow:YES];
    if (export) {
        NSArray *exportFollows = follows.copy;
        exportFollows = [MUBResourcePixivUniversalManager fullPixivMemberURLsWithMemberIDs:exportFollows];
        [exportFollows exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourcePixivFollowUserURLsExportFileName] behavior:MUBFileOpertaionBehaviorShowSuccessLog];
    }
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"共找到 %@ 个关注的用户", follows.count];
    if (follows.count == memberIDs.count) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"%@多个用户的状态, 流程结束", export ? @"导出" : @"查询"];
        return;
    }
    
    NSArray *block1s = [[MUBSQLiteManager defaultManager] getPixivUsersBlockStatusWithMemberIDs:memberIDs blockLevel:1 isEqual:YES];
    if (export) {
        NSArray *exportBlock1s = block1s.copy;
        exportBlock1s = [MUBResourcePixivUniversalManager fullPixivMemberURLsWithMemberIDs:exportBlock1s];
        [exportBlock1s exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourcePixivBlock1UserURLsExportFileName] behavior:MUBFileOpertaionBehaviorShowSuccessLog];
    }
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"共找到 %@ 个确定拉黑的用户", block1s.count];
    if (follows.count + block1s.count == memberIDs.count) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"%@多个用户的状态, 流程结束", export ? @"导出" : @"查询"];
        return;
    }
    
    NSArray *blockNot1s = [[MUBSQLiteManager defaultManager] getPixivUsersBlockStatusWithMemberIDs:memberIDs blockLevel:1 isEqual:NO];
    if (export) {
        NSArray *exportBlockNot1s = blockNot1s.copy;
        exportBlockNot1s = [MUBResourcePixivUniversalManager fullPixivMemberURLsWithMemberIDs:exportBlockNot1s];
        [exportBlockNot1s exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourcePixivBlockNot1UserURLsExportFileName] behavior:MUBFileOpertaionBehaviorShowSuccessLog];
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"共找到 %@ 个未确定拉黑的用户", exportBlockNot1s.count];
    } else {
        NSArray *exportBlockNot1s = blockNot1s.copy;
        exportBlockNot1s = [MUBResourcePixivUniversalManager fullPixivMemberURLsWithMemberIDs:exportBlockNot1s];
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"共找到 %@ 个未确定拉黑的用户:\n%@", exportBlockNot1s.count, exportBlockNot1s.stringValue];
    }
    if (follows.count + block1s.count + blockNot1s.count == memberIDs.count) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"%@多个用户的状态, 流程结束", export ? @"导出" : @"查询"];
        return;
    }
    
    NSArray *fetches = [[MUBSQLiteManager defaultManager] getPixivUsersFetchStatusWithMemberIDs:memberIDs isFetch:YES];
    if (export) {
        NSArray *exportFetches = fetches.copy;
        exportFetches = [MUBResourcePixivUniversalManager fullPixivMemberURLsWithMemberIDs:exportFetches];
        [exportFetches exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourcePixivFetchUserURLsExportFileName] behavior:MUBFileOpertaionBehaviorShowSuccessLog];
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"共找到 %ld 个抓取的用户", exportFetches.count];
    } else {
        NSArray *exportFetches = fetches.copy;
        exportFetches = [MUBResourcePixivUniversalManager fullPixivMemberURLsWithMemberIDs:exportFetches];
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"共找到 %ld 个抓取的用户:\n%@", exportFetches.count, exportFetches.stringValue];
    }
    if (follows.count + block1s.count + blockNot1s.count + fetches.count == memberIDs.count) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"%@多个用户的状态, 流程结束", export ? @"导出" : @"查询"];
        return;
    }
    
    NSMutableArray *news = [NSMutableArray arrayWithArray:memberIDs];
    [news removeObjectsInArray:follows];
    [news removeObjectsInArray:block1s];
    [news removeObjectsInArray:blockNot1s];
    [news removeObjectsInArray:fetches];
    if (export) {
        NSArray *expotedNews = news.copy;
        expotedNews = [MUBResourcePixivUniversalManager fullPixivMemberURLsWithMemberIDs:expotedNews];
        [expotedNews exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourcePixivNewUserURLsExportFileName] behavior:MUBFileOpertaionBehaviorShowSuccessLog];
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"共找到 %ld 个新用户", expotedNews.count];
    } else {
        NSArray *expotedNews = news.copy;
        expotedNews = [MUBResourcePixivUniversalManager fullPixivMemberURLsWithMemberIDs:expotedNews];
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"共找到 %ld 个新用户:\n%@", expotedNews.count, expotedNews.stringValue];
    }
    
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"%@多个用户的状态, 流程结束", export ? @"导出" : @"查询"];
}

//----------------------------------------------------------------------------------------
#pragma mark - showOpenPanel
+ (void)showOpenPanelWithType:(MUBResourcePixivUniversalType)type {
    MUBOpenPanelBehavior behavior = MUBOpenPanelBehaviorNone;
    NSString *message = @"";
    switch (type) {
        case MUBResourcePixivUniversalTypeGenerateIllustURLsFromImageFiles: {
            behavior = MUBOpenPanelBehaviorMultipleFile;
            message = @"需要生成链接的图片文件";
        }
            break;
        case MUBResourcePixivUniversalTypeOrganizeSameIllustIDImageFiles: {
            behavior = MUBOpenPanelBehaviorSingleDir;
            message = @"包含Pixiv图片的根目录";
        }
            break;
        default:
            break;
    }
    if (behavior == MUBOpenPanelBehaviorNone) {
        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"MUBResourcePixivUniversalManager showOpenPanelWithType behavior == MUBOpenPanelBehaviorNone"];
    } else {
        [MUBResourcePixivUniversalManager _showOpenPanelWithType:type behavior:behavior message:message];
    }
}
+ (void)_showOpenPanelWithType:(MUBResourcePixivUniversalType)type behavior:(MUBOpenPanelBehavior)behavior message:(NSString *)message {
    [MUBOpenPanelManager showOpenPanelOnMainWindowWithBehavior:behavior message:[NSString stringWithFormat:@"请选择%@", message] handler:^(NSOpenPanel * _Nonnull openPanel, NSModalResponse result) {
        if (result == NSModalResponseOK) {
            if (behavior & MUBOpenPanelBehaviorMultiple) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSArray *filePaths = [openPanel.URLs bk_map:^id(NSURL *obj) {
                        return [MUBFileManager pathFromOpenPanelURL:obj];
                    }];
                    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"已选择%@: %ld 个项目", message, filePaths.count];
                    [[MUBLogManager defaultManager] saveDefaultLocalLog:[NSString stringWithFormat:@"已选择%@:\n%@", message, filePaths.stringValue]];
                
                    switch (type) {
                        case MUBResourcePixivUniversalTypeGenerateIllustURLsFromImageFiles: {
                            [MUBResourcePixivUniversalManager _generateIllustURLsFromImageFilePaths:filePaths];
                        }
                            break;
                        default:
                            break;
                    }
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *path = [MUBFileManager pathFromOpenPanelURL:openPanel.URLs.firstObject];
                    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"已选择%@：%@", message, path];
                    
                    switch (type) {
                        case MUBResourcePixivUniversalTypeOrganizeSameIllustIDImageFiles: {
                            [MUBResourcePixivUniversalManager _organizeSameIllustIDImageFilesWithRootFolderPath:path];
                        }
                            break;
                        default:
                            break;
                    }
                });
            }
        }
    }];
}

#pragma mark - Generate
+ (void)_generateIllustURLsFromImageFilePaths:(NSArray<NSString *> *)imageFilePaths {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"根据多个图片的文件名称生成对应作品的地址, 流程开始"];
    
    NSMutableArray *result = [NSMutableArray array];
    NSMutableArray *useless = [NSMutableArray array];
    
    for (NSInteger i = 0; i < imageFilePaths.count; i++) {
        NSString *imageFilePath = imageFilePaths[i];
        NSString *imageFileName = imageFilePath.lastPathComponent;
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"\\d+" options:0 error:nil];
        NSArray *matches = [regex matchesInString:imageFileName options:0 range:NSMakeRange(0, imageFileName.length)];
        
        BOOL found = NO;
        for (NSTextCheckingResult *match in matches) {
            NSString *strNumber = [imageFileName substringWithRange:match.range];
            if (strNumber.length == 8 || strNumber.length == 9) {
                found = YES;
                [result addObject:[NSString stringWithFormat:@"https://www.pixiv.net/artworks/%@", strNumber]];
                break;
            }
        }
        if (!found) {
            [useless addObject:imageFilePath];
        }
    }
    
    if (result.count > 0) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"获取到的图片地址如下:\n%@", result.stringValue];
    }
    if (useless.count > 0) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"无法以下文件生成链接:\n%@", useless.stringValue];
    }
    
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"根据多个图片的文件名称生成对应作品的地址, 流程结束"];
}

#pragma mark - Organize
+ (void)_organizeSameIllustIDImageFilesWithRootFolderPath:(NSString *)rootFolderPath {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"将相同Image ID的图片移动到同一个文件夹中, 流程开始"];
    
    NSArray *allImageFilePaths = [MUBFileManager allFilePathsInFolder:rootFolderPath extensions:[MUBSettingManager defaultManager].mimeImageTypes];
    NSMutableArray *pixivFileIDs = [NSMutableArray array];
    for (NSString *imageFilePath in allImageFilePaths) {
        NSString *imageFileName = imageFilePath.lastPathComponent.stringByDeletingPathExtension; // 83124178_p0 - R-18 3DCG
        NSArray *imageFileNameComps = [imageFileName componentsSeparatedByString:@" - "];
        NSString *pixivIllust = imageFileNameComps.firstObject; // 83124178_p0
        NSArray *pixivIllstComps = [pixivIllust componentsSeparatedByString:@"_"];
        [pixivFileIDs addObject:pixivIllstComps.firstObject]; // 83124178
    }
    NSArray *pixivIDs = [NSOrderedSet orderedSetWithArray:pixivFileIDs].array;
    
    for (NSInteger i = 0; i < pixivIDs.count; i++) {
        NSString *pixivID = pixivIDs[i];
        NSArray *imageFilePaths = [allImageFilePaths bk_select:^BOOL(NSString *filePath) {
            return [filePath.lastPathComponent hasPrefix:pixivID];
        }];
        NSString *firstImageFilePath = imageFilePaths.firstObject;
        
        NSString *pixivIDFolderPath = [firstImageFilePath.stringByDeletingLastPathComponent stringByAppendingPathComponent:pixivID];
        [MUBFileManager createFolderAtPath:pixivIDFolderPath];
        
        [imageFilePaths bk_each:^(NSString *imageFilePath) {
            NSString *destFilePath = [pixivIDFolderPath stringByAppendingPathComponent:imageFilePath.lastPathComponent];
            [MUBFileManager moveItemFromPath:imageFilePath toPath:destFilePath];
            
            [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"移动前: %@", imageFilePath];
            [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"移动后: %@", destFilePath];
        }];
    }
    
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"将相同Image ID的图片移动到同一个文件夹中, 流程结束"];
}

//----------------------------------------------------------------------------------------
#pragma mark - Tools
+ (NSString *)numberStringInInput:(NSString *)input {
    NSCharacterSet *numberSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    NSScanner *scanner = [NSScanner scannerWithString:input];
    [scanner scanUpToCharactersFromSet:numberSet intoString:NULL];
    NSString *numberString;
    [scanner scanCharactersFromSet:numberSet intoString:&numberString];
    
    return numberString;
}
+ (BOOL)containsNumberInInput:(NSString *)input {
    return [MUBResourcePixivUniversalManager numberStringInInput:input].integerValue > 0;
}
+ (BOOL)isUserURLWithInput:(NSString *)input {
    return [input containsString:@"users"] || [input containsString:@"member.php"] || [input containsString:@"member_illust.php"] || [input containsString:@"fanbox"] || [MUBResourcePixivUniversalManager containsNumberInInput:input];
}
+ (BOOL)isIllustURLWithInput:(NSString *)input {
    return (![input containsString:@"users"] && ![input containsString:@"member.php"] && ![input containsString:@"member_illust.php"] && ![input containsString:@"fanbox"]) || [MUBResourcePixivUniversalManager containsNumberInInput:input];
}

+ (NSArray<NSString *> *)filterIllustURLsFromInputs:(NSArray<NSString *> *)inputs {
    NSArray *illusts = [inputs filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString * _Nullable input, NSDictionary<NSString *,id> * _Nullable bindings) {
        return ![MUBResourcePixivUniversalManager isUserURLWithInput:input];
    }]];
    if (illusts.count > 0) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"有 %@ 条输入为作品链接，跳过", illusts.count];
        [illusts exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourcePixivIllustURLsExportFileName] behavior:MUBFileOpertaionBehaviorShowSuccessLog];
    }
    
    return [inputs filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString * _Nullable input, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [MUBResourcePixivUniversalManager isIllustURLWithInput:input];
    }]];
}
+ (NSArray<NSString *> *)filterNoneNumberURLsFromInputs:(NSArray<NSString *> *)inputs {
    NSArray *none = [inputs bk_select:^BOOL(NSString *input) {
        return ![MUBResourcePixivUniversalManager containsNumberInInput:input];
    }];
    
    if (none.count > 0) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"有 %@ 条输入非Pixiv地址，跳过", none.count];
        [none exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourcePixivNonePixivMemberIDsExportFileName] behavior:MUBFileOpertaionBehaviorShowSuccessLog];
    }
    
    return [inputs bk_select:^BOOL(NSString *input) {
        return [MUBResourcePixivUniversalManager containsNumberInInput:input];
    }];
}
+ (NSArray<NSString *> *)filterDuplicateURLsFromInputs:(NSArray<NSString *> *)inputs {
    return [NSOrderedSet orderedSetWithArray:inputs].array;
}

+ (NSArray *)fullPixivMemberURLsWithMemberIDs:(NSArray *)memberIDs {
    return [memberIDs bk_map:^id(NSString *obj) {
        return [MUBResourcePixivUniversalManager fullPixivMemberURLWithMemberID:obj];
    }];
}
+ (NSString *)fullPixivMemberURLWithMemberID:(NSString *)memberID {
    return [NSString stringWithFormat:@"https://www.pixiv.net/member_illust.php?id=%@", memberID];
}

@end
