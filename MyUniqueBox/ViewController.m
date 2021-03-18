//
//  ViewController.m
//  MyUniqueBox
//
//  Created by 龚宇 on 2020/9/11.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.inputTextView setFont:[NSFont fontWithName:@"PingFangSC-Regular" size:12.0f]];
    [self.logTextView setFont:[NSFont fontWithName:@"PingFangSC-Regular" size:12.0f]];
    
    [[MUBUIManager defaultManager] updateViewController:self];
}
- (void)viewDidAppear {
    [super viewDidAppear];
    
    [[NSApplication sharedApplication].mainWindow makeFirstResponder:self.inputTextView]; // 设置组件为第一响应
}
- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

#pragma mark - IBAction
- (IBAction)exportButtonDidPress:(NSButton *)sender {
    NSString *input = self.inputTextView.string;
    if (input.length > 0) {
        [input exportToPath:@"/Users/Mercury/Downloads/Input.txt"];
    } else {
        [[MUBLogManager defaultManager] addDefaultLogWithBehavior:MUBLogBehaviorOnViewTimeAppend format:@"没有可导出的输入"];
    }
}
- (IBAction)tempButtonDidPress:(NSButton *)sender {
    [[MUBLogManager defaultManager] addWarningLogWithFormat:@"临时方法执行失败，该方法没有实现"];
    
//    NSString *content = self.inputTextView.string;
//    NSString *content = [NSString stringWithContentsOfFile:@"" encoding:NSUTF8StringEncoding error:nil];
//    NSArray *components = [content componentsSeparatedByString:@"\n"];
//    NSMutableArray *result = [NSMutableArray array];
//    for (NSString *string in components) {
//
//    }
//    self.outputTextView.string = [MRBUtilityManager convertResultArray:result];
}
- (IBAction)cleanButtonDidPress:(NSButton *)sender {
    [[MUBLogManager defaultManager] clean];
}

#pragma mark - Comics
/// 提取ComicGlass中的漫画文件，因为ComicGlass里包含隐藏的文件，因此需要单独提取
- (void)moveComicGlassMangas {
    NSString *originFolder = @"/Users/mercury/Downloads/新已检查的漫画"; // 源文件夹
    NSString *targetFolder = @"/Users/mercury/Downloads/新已检查的漫画 复制层级"; // 通过【复制文件夹的层级】功能生成
    NSArray *filePaths = [MUBFileManager allFilePathsInFolder:originFolder];
    for (NSInteger i = 0; i < filePaths.count; i++) {
        NSString *filePath = filePaths[i];
        NSString *targetFilePath = [filePath stringByReplacingOccurrencesOfString:originFolder withString:targetFolder];
        [MUBFileManager moveItemFromPath:filePath toPath:targetFilePath];
    }
}
- (void)generateFilePathsTXTFile {
    NSArray *filePaths = [MUBFileManager allFilePathsInFolder:@"/Users/mercury/Downloads/iPhone 漫画 复制层级"]; // 移动后不包含ComicGlass隐藏文件的文件夹
    [filePaths exportToPath:@"/Users/mercury/Downloads/iPhone 漫画.txt"];
}
/// 将其他来源的漫画和已经导出的txt文件作对比，名称相同认定为文件相同，移动到废纸篓
- (void)trashDuplicateComicsFromOtherResource {
    NSString *txtFilePath = @""; // generateFilePathsTXTFile方法中生成的TXT文件路径
    NSArray *checkedFilePaths = [[[NSString alloc] initWithContentsOfFile:txtFilePath encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];
    NSArray *checkedFileNames = [checkedFilePaths bk_map:^NSString *(NSString *filePath) {
        return filePath.lastPathComponent;
    }];
    NSString *targetFolder = @"/Users/mercury/Downloads/漫画";
    NSArray *filePaths = [MUBFileManager allFilePathsInFolder:targetFolder];
    NSMutableArray *trashes = [NSMutableArray array];
    
    for (NSInteger i = 0; i < filePaths.count; i++) {
        NSString *filePath = filePaths[i];
        NSString *fileName = filePath.lastPathComponent;
        if ([checkedFileNames indexOfObject:fileName] != NSNotFound) {
            [trashes addObject:filePath];
        }
    }
    
    [MUBFileManager trashFilePaths:trashes];
}
/// 清空没有项目的子文件夹 [递归] [选取根文件夹]
- (void)trashNoItemsFolders {
    @weakify(self);
    [MUBOpenPanelManager showOpenPanelOnMainWindowWithBehavior:MUBOpenPanelBehaviorSingleDir message:[NSString stringWithFormat:@"请选择%@", @"需要清空没有项目的根目录"] handler:^(NSOpenPanel * _Nonnull openPanel, NSModalResponse result) {
        if (result == NSModalResponseOK) {
            @strongify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *path = [MUBFileManager pathFromOpenPanelURL:openPanel.URLs.firstObject];
                [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"已选择%@：%@", @"需要清空没有项目的根目录", path];
                
                [self _trashNoItemsFoldersInFolderPath:path];
            });
        }
    }];
}
- (void)_trashNoItemsFoldersInFolderPath:(NSString *)rootFolderPath {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"清空没有项目的文件夹, 流程开始, 选择的根目录: %@", rootFolderPath];
    
    NSArray *folderPaths = [MUBFileManager allFolderPathsInFolder:rootFolderPath];
    for (NSInteger i = 0; i < folderPaths.count; i++) {
        NSString *folderPath = folderPaths[i];
        NSArray *contentPaths = [MUBFileManager contentPathsInFolder:folderPath];
        if (contentPaths.count != 0) {
            continue;
        }
        
        [MUBFileManager trashFilePath:folderPath];
        
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"将 %@ 移动到废纸篓", folderPath];
    }
    
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"清空没有项目的文件夹, 流程结束"];
}
/// 将不同的文件夹合并
- (void)combineMultipleFolders {
    NSArray *sourceFolderPaths = @[@""]; // 源文件夹
    NSString *targetFolderPath = @""; // 目标文件夹
    NSMutableArray *trashes = [NSMutableArray array];
    
    // 单纯的替换根文件夹
    for (NSInteger i = 0; i < sourceFolderPaths.count; i++) {
        NSString *sourceFolderPath = sourceFolderPaths[i];
        NSArray *sourceFilePaths = [MUBFileManager allFilePathsInFolder:sourceFolderPath];
        for (NSInteger j = 0; j < sourceFilePaths.count; j++) {
            NSString *sourceFilePath = sourceFilePaths[j];
            NSString *targetFilePath = [sourceFilePath stringByReplacingOccurrencesOfString:sourceFolderPath withString:targetFolderPath];
            
            // 如果目标文件存在，那么忽略
            if ([MUBFileManager fileExistsAtPath:targetFilePath]) {
                [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"%@ 文件已存在，移动到废纸篓", [sourceFilePath stringByReplacingOccurrencesOfString:sourceFolderPath withString:@""]];
                [trashes addObject:sourceFilePath];
                
                continue;
            }
            
            // 先判断目标地址的父文件夹是否存在，如果不存在创建该文件夹
            if (![MUBFileManager contentIsFolderAtPath:targetFilePath.stringByDeletingLastPathComponent]) {
                [MUBFileManager createFolderAtPath:targetFilePath.stringByDeletingLastPathComponent];
            }
            
            [MUBFileManager moveItemFromPath:sourceFilePath toPath:targetFilePath];
            
            [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"将: %@", sourceFilePath];
            [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"合并至: %@", targetFilePath];
        }
    }
    
    [MUBFileManager trashFilePaths:trashes];
}

@end
