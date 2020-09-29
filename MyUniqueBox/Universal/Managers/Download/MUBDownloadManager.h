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

@class MUBDownloadManager;

@protocol MUBDownloadDelegate <NSObject>

@optional
- (void)downloadManager:(MUBDownloadManager *)manager didFinishDownloading:(BOOL)success;

@end

@interface MUBDownloadManager : NSObject

@property (weak) id<MUBDownloadDelegate> delegate;

+ (instancetype)managerWithSettingModel:(MUBDownloadSettingModel *)model URLs:(NSArray<NSString *> *)URLs downloadFilePath:(NSString * _Nullable)downloadFilePath;

- (void)start;

@end

NS_ASSUME_NONNULL_END
