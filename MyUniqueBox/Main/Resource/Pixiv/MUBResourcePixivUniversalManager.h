//
//  MUBResourcePixivUniversalManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/10/01.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MUBResourcePixivUniversalType) {
    MUBResourcePixivUniversalTypeUpdateBlock1,
    MUBResourcePixivUniversalTypeUpdateBlock2,
    MUBResourcePixivUniversalTypeFollowStatus,
    MUBResourcePixivUniversalTypeBlockStatus,
    MUBResourcePixivUniversalTypeFetchStatus,
    MUBResourcePixivUniversalTypeGenerateIllustURLsFromImageFiles,
    MUBResourcePixivUniversalTypeOrganizeSameIllustIDImageFiles,
    MUBResourcePixivUniversalTypeRemoveUsersDownloadRecords,
    MUBResourcePixivUniversalTypeExportFollowAndBlockUsers,
};

@interface MUBResourcePixivUniversalManager : NSObject

+ (void)getInputsWithType:(MUBResourcePixivUniversalType)type;
+ (void)showOpenPanelWithType:(MUBResourcePixivUniversalType)type;

@end

NS_ASSUME_NONNULL_END
