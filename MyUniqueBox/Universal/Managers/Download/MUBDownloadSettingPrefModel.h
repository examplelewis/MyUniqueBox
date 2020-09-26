//
//  MUBDownloadSettingPrefModel.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/26.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MUBDownloadSettingPrefModel : MUBModel

@property (strong) NSString *prefName;
@property (assign) NSInteger prefTag;

@property (strong) NSString *downloadFolderPath;
@property (strong, nullable) NSDictionary *httpHeaders;

@property (assign) BOOL showFinishAlert;
@property (assign) NSInteger maxConcurrentCount;
@property (assign) NSInteger maxRedownloadTimes;
@property (assign) NSTimeInterval timeoutInterval;

- (NSDictionary *)toDictionary;

@end

NS_ASSUME_NONNULL_END
