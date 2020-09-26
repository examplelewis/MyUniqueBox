//
//  MUBDownloadSettingModel.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/23.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBDownloadSettingPrefModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MUBDownloadSettingFileMode) {
    MUBDownloadSettingFileModeNone = 0,
    MUBDownloadSettingFileModeInput,
    MUBDownloadSettingFileModeChooseFile,
};

@interface MUBDownloadSettingModel : MUBDownloadSettingPrefModel

@property (strong) NSString *filePath;
@property (strong) NSString *fileName;
@property (assign) MUBDownloadSettingFileMode fileMode;

@property (strong, nullable) NSDictionary *renameInfo; // 格式: @{%url%: @"xxx.jpg"}

- (void)updatePrefTag;

@end

NS_ASSUME_NONNULL_END
