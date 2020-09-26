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
    MUBDownloadSettingFileModeInput,
    MUBDownloadSettingFileModeChooseFile,
};

@interface MUBDownloadSettingModel : MUBDownloadSettingPrefModel

@property (strong) NSString *filePath;
@property (strong) NSString *fileName;
@property (assign) MUBDownloadSettingFileMode fileMode;

@end

NS_ASSUME_NONNULL_END
