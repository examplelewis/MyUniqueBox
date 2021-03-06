//
//  MUBFileUniversalManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/16.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MUBFileUniversalType) {
    MUBFileUniversalTypeRename32BitMD5ByFolder,
    MUBFileUniversalTypeRename32BitMD5ByFile,
    MUBFileUniversalTypeRename32BitMD5BySeries,
    MUBFileUniversalTypeSearchHiddenFile,
    MUBFileUniversalTypeRenameAsSuperFodlerNameOnSingleFolder,
    MUBFileUniversalTypeRenameAsSuperFodlerNameOnSingleFile,
    MUBFileUniversalTypeRenameAsSuperFodlerNameOnSingleContent,
    MUBFileUniversalTypeRenameAddSuperFolderNameOnAllFolders,
    MUBFileUniversalTypeRenameAddSuperFolderNameOnAllFiles,
    MUBFileUniversalTypeRenameAddSuperFolderNameOnAllContents,
    MUBFileUniversalTypeCopyFolderHierarchy,
    MUBFileUniversalTypeExtractSingleFolder,
    MUBFileUniversalTypeExtractSingleFile,
    MUBFileUniversalTypeTrashNoItemsFolder,
    MUBFileUniversalTypeTrashAntiImageVideoFiles,
    MUBFileUniversalTypeCombineMultipleFolders,
};

@interface MUBFileUniversalManager : NSObject

+ (void)showOpenPanelWithType:(MUBFileUniversalType)type;
+ (void)operationWithType:(MUBFileUniversalType)type;

@end

NS_ASSUME_NONNULL_END
