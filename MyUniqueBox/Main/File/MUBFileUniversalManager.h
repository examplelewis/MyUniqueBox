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
    MUBFileUniversalTypeSearchHiddenFile,
    MUBFileUniversalTypeRenameSingleFolder,
    MUBFileUniversalTypeRenameSingleFile,
    MUBFileUniversalTypeRenameSingleContent,
};

@interface MUBFileUniversalManager : NSObject

+ (void)showOpenPanelWithType:(MUBFileUniversalType)type;

@end

NS_ASSUME_NONNULL_END
