//
//  MUBDownloadManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/23.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUBDownloadSettingModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MUBDownloadManager : NSObject

- (instancetype)initWithSettingModel:(MUBDownloadSettingModel *)model URLs:(NSArray<NSString *> *)URLs;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (void)start;

@end

NS_ASSUME_NONNULL_END
