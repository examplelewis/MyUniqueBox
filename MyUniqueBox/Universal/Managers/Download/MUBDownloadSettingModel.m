//
//  MUBDownloadSettingModel.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/23.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBDownloadSettingModel.h"

@implementation MUBDownloadSettingModel

- (void)updatePrefTag {
    if (self.prefTag % 100 >= 50) {
        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"MUBDownloadSettingModel updatePrefTag: % 100 >= 50"];
    }
    
    if (self.fileMode == MUBDownloadSettingFileModeInput) {
        self.prefTag = self.prefTag / 100 * 100 + self.prefTag % 100 * 2 - 1;
    } else if (self.fileMode == MUBDownloadSettingFileModeChooseFile) {
        self.prefTag = self.prefTag / 100 * 100 + self.prefTag % 100 * 2;
    }
}

@end
