//
//  MUBDownloadSettingPrefModel.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/26.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBDownloadSettingPrefModel.h"

@implementation MUBDownloadSettingPrefModel

// 返回一个 Dict，将 Model 属性名对映射到 JSON 的 Key。Key 为 Property，Value 为 JSON 的 Key
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"prefName"                     : @"pref_name",
        @"prefTag"                      : @"pref_tag",
        @"downloadFolderPath"           : @"download_folder_path",
        @"httpHeaders"                  : @"http_headers",
        @"showFinishAlert"              : @"show_finish_alert",
        @"maxConcurrentCount"           : @"max_concurrent_count",
        @"maxRedownloadTimes"           : @"max_redownload_times",
        @"timeoutInterval"              : @"timeout_interval",
    };
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *toDictionary = [NSMutableDictionary new];
    
    if (self.prefName.isNotEmpty) {
        [toDictionary setObject:self.prefName forKey:@"pref_name"];
    }
    [toDictionary setObject:@(self.prefTag) forKey:@"pref_tag"];
    
    if (self.downloadFolderPath.isNotEmpty) {
        [toDictionary setObject:self.downloadFolderPath forKey:@"download_folder_path"];
    }
    if (self.httpHeaders.isNotEmpty) {
        [toDictionary setObject:self.httpHeaders forKey:@"http_headers"];
    }
    
    [toDictionary setObject:@(self.showFinishAlert) forKey:@"show_finish_alert"];
    [toDictionary setObject:@(self.maxConcurrentCount) forKey:@"max_concurrent_count"];
    [toDictionary setObject:@(self.maxRedownloadTimes) forKey:@"max_redownload_times"];
    [toDictionary setObject:@(self.timeoutInterval) forKey:@"timeout_interval"];
    
    return toDictionary.copy;
}


@end
