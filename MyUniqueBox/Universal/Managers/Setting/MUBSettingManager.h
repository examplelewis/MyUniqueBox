//
//  MUBSettingManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUBSettingWeiboModels.h"
#import "MUBSettingDeviantartModels.h"
#import "MUBSettingFileModels.h"

NS_ASSUME_NONNULL_BEGIN

@interface MUBSettingManager : NSObject

@property (strong, readonly) MUBSettingWeiboAuthModel *weiboAuthModel;
@property (strong, readonly) MUBSettingWeiboBoundaryModel *weiboBoundaryModel;
@property (strong, readonly) MUBSettingDeviantartAuthModel *deviantartAuthModel;
@property (strong, readonly) MUBSettingDeviantartBoundaryModel *deviantartBoundaryModel;
@property (strong, readonly) MUBSettingFileSearchCharactersModel *fileSearchCharactersModel;

@property (strong, readonly) NSArray *mimeImageTypes;
@property (strong, readonly) NSArray *mimeVideoTypes;
@property (strong, readonly) NSArray *mimeImageAndVideoTypes;

@property (strong, readonly) NSString *mainFolderPath;
@property (strong, readonly) NSString *mainDatabasesFolderPath;
@property (strong, readonly) NSString *downloadFolderPath;
@property (strong, readonly) NSString *pixivUtilDBFilePath;
@property (strong, readonly) NSString *preferenceFilePath;

#pragma mark - Lifecycle
+ (instancetype)defaultManager;

#pragma mark - Configure
- (void)updatePreferences;
- (void)updateWeiboBoundaryModel;

#pragma mark - Types
- (BOOL)isImageAtFilePath:(NSString *)filePath;
- (BOOL)isVideoAtFilePath:(NSString *)filePath;

#pragma mark - Paths
- (NSString *)pathOfContentInDownloadFolder:(NSString *)component;
- (NSString *)pathOfContentInMainFolder:(NSString *)component;
- (NSString *)pathOfContentInMainDatabasesFolder:(NSString *)component;

@end

NS_ASSUME_NONNULL_END
