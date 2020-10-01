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
                switch (type) {
                    case MUBResourcePixivUniversalTypeGenerateIllustURLsFromImageFiles: {
                        NSArray *imageFilePaths = [openPanel.URLs bk_map:^id(NSURL *obj) {
                            return [MUBFileManager pathFromOpenPanelURL:obj];
                        }];
                        
                        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"已选择%@:\n%@", message, imageFilePaths.stringValue];
                        
                        [MUBResourcePixivUniversalManager _generateIllustURLsFromImageFilePaths:imageFilePaths];
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
    [[MUBLogManager defaultManager] addErrorLogWithFormat:@"根据多个图片的文件名称生成对应作品的地址, 流程开始"];
    
    NSMutableArray *result = [NSMutableArray array];
    NSMutableArray *useless = [NSMutableArray array];
    
    for (NSInteger i = 0; i < imageFilePaths.count; i++) {
        NSString *imageFilePath = imageFilePaths[i];
        NSString *imageFileName = imageFilePath.lastPathComponent;
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"\\d+" options:0 error:nil];
        NSArray *matches = [regex matchesInString:imageFileName options:0 range:NSMakeRange(0, imageFileName.length)];
        
        for (NSTextCheckingResult *match in matches) {
            NSString *strNumber = [imageFileName substringWithRange:match.range];
            if (strNumber.length == 8 || strNumber.length == 9) {
                [result addObject:[NSString stringWithFormat:@"https://www.pixiv.net/artworks/%@", strNumber]];
            } else {
                [useless addObject:imageFilePath];
            }
        }
    }
    
    if (result.count > 0) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"获取到的图片地址如下:\n%@", result.stringValue];
    }
    if (useless.count > 0) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"无法以下文件生成链接:\n%@", useless.stringValue];
    }
    
    [[MUBLogManager defaultManager] addErrorLogWithFormat:@"根据多个图片的文件名称生成对应作品的地址, 流程结束"];
}

#pragma mark - Organize
+ (void)_organizeSameIllustIDImageFilesWithRootFolderPath:(NSString *)rootFolderPath {
    [[MUBLogManager defaultManager] addErrorLogWithFormat:@"将相同Image ID的图片移动到同一个文件夹中, 流程开始"];
    
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
            
            [[MUBLogManager defaultManager] addErrorLogWithFormat:@"移动前: %@", imageFilePath];
            [[MUBLogManager defaultManager] addErrorLogWithFormat:@"移动后: %@", destFilePath];
        }];
    }
    
    [[MUBLogManager defaultManager] addErrorLogWithFormat:@"将相同Image ID的图片移动到同一个文件夹中, 流程结束"];
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
