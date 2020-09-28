//
//  MUBDownloadSettingManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/23.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBDownloadSettingManager.h"
#import "MUBMenuItemManager.h"

static NSInteger const kDefaultTag = 4000000;

@interface MUBDownloadSettingManager ()

@property (copy) NSArray *prefModels;
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
    [self copyDownloadPrefsFolder]; // 将项目中配置好的文件拷贝到文件夹
    [self updateAllPreferences]; // 获取所有配置
}
- (void)copyDownloadPrefsFolder {
    NSArray *downloadPrefFilePaths = [MUBFileManager filePathsInFolder:[[NSBundle mainBundle] resourcePath] extensions:@[@"plist"]];
    downloadPrefFilePaths = [downloadPrefFilePaths bk_select:^BOOL(NSString *filePath) {
        return [filePath.lastPathComponent hasPrefix:@"Download Prefs"];
    }];
    
    for (NSString *downloadPrefFilePath in downloadPrefFilePaths) {
        NSString *destFilePath = [self.prefsFolderPath stringByAppendingPathComponent:[downloadPrefFilePath.lastPathComponent stringByReplacingOccurrencesOfString:@"Download Prefs " withString:@""]];
        if (![MUBFileManager fileExistsAtPath:destFilePath]) {
            [MUBFileManager copyItemFromPath:downloadPrefFilePath toPath:destFilePath];
        }
    }
}
- (void)updateAllPreferences {
    NSMutableArray *models = [NSMutableArray array];
    NSArray *filePaths = [MUBFileManager filePathsInFolder:self.prefsFolderPath extensions:@[@"plist"]];
    
    for (NSInteger i = 0; i < filePaths.count; i++) {
        NSString *filePath = filePaths[i];
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:filePath];
        
        MUBDownloadSettingModel *inputModel = [MUBDownloadSettingModel yy_modelWithJSON:dictionary];
        inputModel.filePath = filePath;
        inputModel.fileName = filePath.lastPathComponent.stringByDeletingPathExtension;
        inputModel.fileMode = MUBDownloadSettingFileModeInput;
        [inputModel updatePrefTag];
        [models addObject:inputModel];
        
        MUBDownloadSettingModel *chooseFileModel = [MUBDownloadSettingModel yy_modelWithJSON:dictionary];
        chooseFileModel.filePath = filePath;
        chooseFileModel.fileName = filePath.lastPathComponent.stringByDeletingPathExtension;
        chooseFileModel.fileMode = MUBDownloadSettingFileModeChooseFile;
        [chooseFileModel updatePrefTag];
        [models addObject:chooseFileModel];
    }
    [models sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"prefTag" ascending:YES]]];
    
    self.prefModels = [models copy];
}
- (void)updateDefaultPrefrenceWithModel:(MUBDownloadSettingModel *)model {
    [self updatePreferenceWithName:@"default" model:model];
}
- (void)updatePreferenceWithName:(NSString *)name model:(MUBDownloadSettingModel *)model {
    // 先判断两个 model 是否相等
    // 先写到文件里
    
    [self updateAllPreferences];
}

#pragma mark - Pref Model
// menuItemTag 和 prefTag 相同
- (MUBDownloadSettingModel *)prefModelFromMenuItemTag:(NSInteger)tag {
    NSArray *prefModels = [self.prefModels bk_select:^BOOL(MUBDownloadSettingModel *model) {
        return model.prefTag == tag;
    }];
    if (prefModels.count == 0) {
        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"MUBDownloadSettingManager prefModelFromMenuItemTag prefModels.count == 0"];
        return nil;
    }
    
    return prefModels.firstObject;
}

#pragma mark - Menu Item
- (void)updateMenuItems {
    NSMenu *subMenu = [NSMenu new];
    subMenu.title = @"下载【功能已通过测试】";
    
    NSInteger prefTag = 0;
    for (NSInteger i = 0; i < self.prefModels.count; i++) {
        MUBDownloadSettingModel *model = self.prefModels[i];
        
        if (i % 2 == 0) {
            if (prefTag / 100 != (model.prefTag - kDefaultTag) / 100) {
                prefTag = model.prefTag - kDefaultTag;
                [subMenu addItem:[NSMenuItem separatorItem]];
            }
        }
        
        NSMenuItem *menuItem = [NSMenuItem new];
        menuItem.title = [NSString stringWithFormat:@"%@ [%@]", model.prefName, model.fileMode == MUBDownloadSettingFileModeInput ? @"输入" : @"选择文件"];
        menuItem.tag = model.prefTag;
        if (model.fileMode == MUBDownloadSettingFileModeChooseFile) {
            menuItem.alternate = YES;
            menuItem.keyEquivalentModifierMask = NSEventModifierFlagOption;
        }
        menuItem.target = self;
        menuItem.action = @selector(downloadMenuItemDidPress:);
        
        [subMenu addItem:menuItem];
    }
    
    [MUBUIManager defaultManager].appDelegate.downloadRootMenuItem.submenu = subMenu;
}
- (void)downloadMenuItemDidPress:(NSMenuItem *)sender {
    [MUBMenuItemManager customMenuItemDidPress:sender];
}

@end
