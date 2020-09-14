//
//  MUBSettingManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUBSettingWeiboAuthModel.h"
#import "MUBSettingDeviantartAuthModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MUBSettingManager : NSObject

@property (strong, readonly) MUBSettingWeiboAuthModel *weiboAuthModel;
@property (strong, readonly) MUBSettingDeviantartAuthModel *deviantartAuthModel;

@property (strong, readonly) NSString *mainFolderPath;
@property (strong, readonly) NSString *downloadFolderPath;

+ (instancetype)defaultManager;

- (void)updatePreferences;

- (NSString *)pathOfContentInDownloadFolder:(NSString *)component;

@end

NS_ASSUME_NONNULL_END
