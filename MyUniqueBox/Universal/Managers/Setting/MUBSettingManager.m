//
//  MUBSettingManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBSettingManager.h"

static NSString * const MUBMainFolderPath = @"/Users/mercury/SynologyDrive/~同步文件夹/同步文档/MyUniqueBox";
static NSString * const MUBPixivUtilDBFilePath = @"/Users/Mercury/SynologyDrive/~同步文件夹/Tool/pixivutil/db.sqlite";

@implementation MUBSettingManager

#pragma mark - Lifecycle
+ (instancetype)defaultManager {
    static MUBSettingManager *defaultManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [[self alloc] init];
    });
    
    return defaultManager;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        if ([MUBFileManager fileExistsAtPath:MUBMainFolderPath]) {
            _mainFolderPath = MUBMainFolderPath;
            _mainDatabasesFolderPath = [MUBMainFolderPath stringByAppendingPathComponent:@"Databases"];
        } else {
            [MUBAlertManager showCriticalAlertOnMainWindowWithMessage:@"主文件夹不存在" info:[NSString stringWithFormat:@"需要检查:\n%@", MUBMainFolderPath] runModal:NO handler:nil];
        }
        
        if ([MUBFileManager fileExistsAtPath:MUBPixivUtilDBFilePath]) {
            _pixivUtilDBFilePath = MUBPixivUtilDBFilePath;
        } else {
            [MUBAlertManager showCriticalAlertOnMainWindowWithMessage:@"PixivUtil 数据库文件不存在" info:[NSString stringWithFormat:@"需要检查:\n%@", MUBPixivUtilDBFilePath] runModal:NO handler:nil];
        }
        
        [self setupPaths];
        [self updatePreferences];
        
        
//        [self migrateMyResourceBoxPreferences];
    }
    
    return self;
}

#pragma mark - Configure
- (void)setupPaths {
    NSArray *downloadDirs = [[NSFileManager defaultManager] URLsForDirectory:NSDownloadsDirectory inDomains:NSUserDomainMask];
    if (downloadDirs.count > 0) {
        _downloadFolderPath = [MUBFileManager pathFromOpenPanelURL:downloadDirs.firstObject];
    } else {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"当前用户不存在下载文件夹"];
    }
    
    _preferenceFilePath = [self pathOfContentInMainFolder:@"MUBPreference.plist"];
}
- (void)updatePreferences {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:[self pathOfContentInMainFolder:@"MUBPreference.plist"]];
    NSDictionary *newPrefs = [NSDictionary dictionaryWithContentsOfFile:[self pathOfContentInMainFolder:@"MUBPreferenceNew.plist"]];
    
    _weiboAuthModel = [MUBSettingWeiboAuthModel yy_modelWithJSON:[prefs valueForKeyPath:@"Weibo.Auth"]];
    _weiboBoundaryModel = [MUBSettingWeiboBoundaryModel yy_modelWithJSON:[prefs valueForKeyPath:@"Weibo.Boundary"]];
    _deviantartAuthModel = [MUBSettingDeviantartAuthModel yy_modelWithJSON:[prefs valueForKeyPath:@"DeviantArt.Auth"]];
    _deviantartBoundaryModel = [MUBSettingDeviantartBoundaryModel yy_modelWithJSON:[prefs valueForKeyPath:@"DeviantArt.Boundary"]];
    
    _mimeImageTypes = [[prefs valueForKeyPath:@"MIMEType.ImageTypes"] copy];
    _mimeVideoTypes = [[prefs valueForKeyPath:@"MIMEType.VideoTypes"] copy];
    _mimeImageAndVideoTypes = [self.mimeImageTypes arrayByAddingObjectsFromArray:self.mimeVideoTypes];
    
    _fileSearchCharactersModel = [MUBSettingFileSearchCharactersModel yy_modelWithJSON:[newPrefs valueForKeyPath:@"File.SearchCharacters"]];
    _StringEmojis = [newPrefs valueForKeyPath:@"String.Emojis"];
}
- (void)updateWeiboBoundaryModel {
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:[self pathOfContentInMainFolder:@"MUBPreference.plist"]];
    NSDictionary *dictionary = [_weiboBoundaryModel yy_modelToJSONObject];
    [prefs setValue:dictionary forKeyPath:@"Weibo.Boundary"];
    [prefs exportToPlistPath:[self pathOfContentInMainFolder:@"MUBPreference.plist"]];
}

#pragma mark - Types
- (BOOL)isImageAtFilePath:(NSString *)filePath {
    BOOL isImage = NO;
    for (NSString *extension in self.mimeImageTypes) {
        isImage = [filePath.pathExtension caseInsensitiveCompare:extension];
        if (isImage) {
            break;
        }
    }
    
    return isImage;
}
- (BOOL)isVideoAtFilePath:(NSString *)filePath {
    BOOL isVideo = NO;
    for (NSString *extension in self.mimeVideoTypes) {
        isVideo = [filePath.pathExtension caseInsensitiveCompare:extension];
        if (isVideo) {
            break;
        }
    }
    
    return isVideo;
}

#pragma mark - Paths
- (NSString *)pathOfContentInDownloadFolder:(NSString *)component {
    return [self.downloadFolderPath stringByAppendingPathComponent:component];
}
- (NSString *)pathOfContentInMainFolder:(NSString *)component {
    return [self.mainFolderPath stringByAppendingPathComponent:component];
}
- (NSString *)pathOfContentInMainDatabasesFolder:(NSString *)component {
    return [self.mainDatabasesFolderPath stringByAppendingPathComponent:component];
}

#pragma mark - Migrate
- (void)migrateMyResourceBoxPreferences {
    NSMutableDictionary *Authorization = [NSMutableDictionary dictionaryWithContentsOfFile:[self pathOfContentInMainFolder:@"MRBResourceBox/Authorization.plist"]];
    NSMutableDictionary *DeviantartLoginInfo = [NSMutableDictionary dictionaryWithContentsOfFile:[self pathOfContentInMainFolder:@"MRBResourceBox/DeviantartLoginInfo.plist"]];
    NSMutableDictionary *DeviantartPres = [NSMutableDictionary dictionaryWithContentsOfFile:[self pathOfContentInMainFolder:@"MRBResourceBox/DeviantartPres.plist"]];
    NSMutableDictionary *Preference = [NSMutableDictionary dictionaryWithContentsOfFile:[self pathOfContentInMainFolder:@"MRBResourceBox/Preference.plist"]];
    
    NSMutableDictionary *mubPrefs = [NSMutableDictionary dictionary];
    mubPrefs[@"Weibo"] = @{
        @"Auth": Authorization,
        @"Boundary": Authorization,
    };
    mubPrefs[@"DeviantArt"] = @{
        @"Auth": DeviantartLoginInfo,
        @"Boundary": @{@"published_time": DeviantartPres[@"publishedTime"]},
    };
    mubPrefs[@"MIMEType"] = @{
        @"ImageTypes": Preference[@"mime_image_types"],
        @"VideoTypes": Preference[@"mime_video_types"],
    };
    
    [mubPrefs writeToFile:[self pathOfContentInMainFolder:@"MUBPreference.plist"] atomically:YES];
}

@end
