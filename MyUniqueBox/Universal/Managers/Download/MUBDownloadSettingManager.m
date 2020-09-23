//
//  MUBDownloadSettingManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/23.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBDownloadSettingManager.h"


@interface MUBDownloadSettingManager ()

@property (copy) NSString *prefsFolderPath;
@property (copy) NSString *defaultPrefFilePath;

@end

@implementation MUBDownloadSettingManager

#pragma mark - Lifecycle
+ (instancetype)defaultManager {
    static MUBDownloadSettingManager *defaultManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [[self alloc] init];
    });
    
    return defaultManager;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.prefsFolderPath = [[MUBSettingManager defaultManager] pathOfContentInMainFolder:@"Download Prefs"];
        self.defaultPrefFilePath = [self.prefsFolderPath stringByAppendingPathComponent:@"default.plist"];
    }
    
    return self;
}

#pragma mark - Update
- (void)updatePreferences {
    [MUBFileManager createFolderAtPath:self.prefsFolderPath]; // 新建文件夹
    [self updateDefaultPreference]; // 添加/获取默认配置
    [self updateAllPreferences]; // 获取所有配置
}
- (void)updateDefaultPreference {
    if (![MUBFileManager fileExistsAtPath:self.defaultPrefFilePath]) {
        _defaultPrefModel = [MUBDownloadSettingModel new];
        self.defaultPrefModel.prefName = @"default";
        self.defaultPrefModel.downloadFolderPath = [MUBSettingManager defaultManager].downloadFolderPath;
        self.defaultPrefModel.httpHeaders = nil;
//        self.defaultModel.renameInfo = nil;
        self.defaultPrefModel.showFinishAlert = YES;
        self.defaultPrefModel.maxConcurrentOperationCount = 15;
        self.defaultPrefModel.maxRedownloadTimes = 3;
        self.defaultPrefModel.timeoutInterval = 30;
        
        [self.defaultPrefModel.toDictionary exportToPlistPath:self.defaultPrefFilePath];
    } else {
        NSDictionary *defaultPrefDictionary = [NSDictionary dictionaryWithContentsOfFile:self.defaultPrefFilePath];
        _defaultPrefModel = [MUBDownloadSettingModel yy_modelWithJSON:defaultPrefDictionary];
    }
}
- (void)updateAllPreferences {
    NSArray *filePaths = [MUBFileManager filePathsInFolder:self.prefsFolderPath extensions:@[@"plist"]];
    _prefModels = [filePaths bk_map:^MUBDownloadSettingModel *(NSString *filePath) {
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:filePath];
        MUBDownloadSettingModel *model = [MUBDownloadSettingModel yy_modelWithJSON:dictionary];
        model.prefName = filePath.lastPathComponent.stringByDeletingPathExtension;
        
        return model;
    }];
}
- (void)updateDefaultPrefrenceWithModel:(MUBDownloadSettingModel *)model {
    [self updatePreferenceWithName:@"default" model:model];
}
- (void)updatePreferenceWithName:(NSString *)name model:(MUBDownloadSettingModel *)model {
    // 先判断两个 model 是否相等
    // 先写到文件里
    
    if ([name isEqualToString:@"default"]) {
        [self updateDefaultPreference];
    }
    [self updateAllPreferences];
}


@end
