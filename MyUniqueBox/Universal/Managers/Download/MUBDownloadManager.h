//
//  MUBDownloadManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/23.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MUBDownloadSettingManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface MUBDownloadManager : NSObject

@property (nonatomic, copy) void(^onFinish)(void);

+ (instancetype)managerWithSettingModel:(MUBDownloadSettingModel *)model URLs:(NSArray<NSString *> *)URLs downloadFilePath:(NSString * _Nullable)downloadFilePath;

- (void)start;

@end

NS_ASSUME_NONNULL_END
