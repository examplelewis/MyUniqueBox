//
//  MUBMangaUniversalManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 2021/3/20.
//  Copyright © 2021 龚宇. All rights reserved.
//

#import "MUBMangaUniversalManager.h"

@implementation MUBMangaUniversalManager

/// 提取ComicGlass中的漫画文件，因为ComicGlass里包含隐藏的文件，因此需要单独提取
+ (void)moveComicGlassMangas {
    NSString *originFolder = @"/Users/mercury/Downloads/新已检查的漫画"; // 源文件夹
    NSString *targetFolder = @"/Users/mercury/Downloads/新已检查的漫画 复制层级"; // 通过【复制文件夹的层级】功能生成
    NSArray *filePaths = [MUBFileManager allFilePathsInFolder:originFolder];
    for (NSInteger i = 0; i < filePaths.count; i++) {
        NSString *filePath = filePaths[i];
        NSString *targetFilePath = [filePath stringByReplacingOccurrencesOfString:originFolder withString:targetFolder];
        [MUBFileManager moveItemFromPath:filePath toPath:targetFilePath];
    }
}
+ (void)generateFilePathsTXTFile {
    NSArray *filePaths = [MUBFileManager allFilePathsInFolder:@"/Users/mercury/Downloads/iPhone 漫画 复制层级"]; // 移动后不包含ComicGlass隐藏文件的文件夹
    [filePaths exportToPath:@"/Users/mercury/Downloads/iPhone 漫画.txt"];
}
/// 将其他来源的漫画和已经导出的txt文件作对比，名称相同认定为文件相同，移动到废纸篓
+ (void)trashDuplicateComicsFromOtherResource {
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

@end
