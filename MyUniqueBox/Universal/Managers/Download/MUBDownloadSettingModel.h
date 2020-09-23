//
//  MUBDownloadSettingModel.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/23.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MUBDownloadSettingModel : MUBModel

@property (strong) NSString *prefName;

@property (strong) NSString *downloadFolderPath;
@property (strong, nullable) NSDictionary *httpHeaders;
//@property (strong, nullable) NSDictionary *renameInfo; // 格式: @{%url%: @"xxx.jpg"}

@property (assign) BOOL showFinishAlert;
@property (assign) NSInteger maxConcurrentOperationCount;
@property (assign) NSInteger maxRedownloadTimes;
@property (assign) NSTimeInterval timeoutInterval;

- (NSDictionary *)toDictionary;

@end

NS_ASSUME_NONNULL_END
