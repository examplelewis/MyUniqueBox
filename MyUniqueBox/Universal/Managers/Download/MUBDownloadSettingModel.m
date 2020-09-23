//
//  MUBDownloadSettingModel.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/23.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBDownloadSettingModel.h"

@implementation MUBDownloadSettingModel

// 返回一个 Dict，将 Model 属性名对映射到 JSON 的 Key。Key 为 Property，Value 为 JSON 的 Key
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"downloadFolderPath"  : @"download_folder_path",
        @"httpHeaders"    : @"http_headers",
        @"renameInfo"    : @"rename_info",
        @"showFinishAlert"    : @"show_finish_alert",
        @"maxConcurrentOperationCount"  : @"max_concurrent_operation_count",
        @"maxRedownloadTimes" : @"max_redownload_times",
        @"timeoutInterval"    : @"timeout_interval",
    };
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *toDictionary = [NSMutableDictionary new];
    
    if (self.downloadFolderPath.isNotEmpty) {
        [toDictionary setObject:self.downloadFolderPath forKey:@"download_folder_path"];
    }
    if (self.httpHeaders.isNotEmpty) {
        [toDictionary setObject:self.httpHeaders forKey:@"http_headers"];
    }
//    if (self.renameInfo.isNotEmpty) {
//        [toDictionary setObject:self.renameInfo forKey:@"rename_info"];
//    }
    [toDictionary setObject:@(self.showFinishAlert) forKey:@"show_finish_alert"];
    [toDictionary setObject:@(self.maxConcurrentOperationCount) forKey:@"max_concurrent_operation_count"];
    [toDictionary setObject:@(self.maxRedownloadTimes) forKey:@"max_redownload_times"];
    [toDictionary setObject:@(self.timeoutInterval) forKey:@"timeout_interval"];
    
    return toDictionary.copy;
}

@end
