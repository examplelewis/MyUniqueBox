//
//  MUBFileManager.m
//  MyComicView
//
//  Created by 龚宇 on 16/08/03.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "MUBFileManager.h"

@implementation MUBFileManager

#pragma mark - Create
+ (BOOL)createFolderAtPath:(NSString *)folderPath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:folderPath]) {
        return YES;
    } else {
        NSError *error;
        if ([[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            return YES;
        } else {
            [[MUBLogManager defaultManager] addErrorLogWithFormat:@"创建文件夹 %@ 时发生错误: \n%@", folderPath, [error localizedDescription]];
            return NO;
        }
    }
}

#pragma mark - Trash
+ (BOOL)trashFilePath:(NSString *)filePath {
    return [self trashFileURL:[self fileURLFromFilePath:filePath] resultItemURL:nil];
}
+ (BOOL)trashFileURL:(NSURL *)fileURL {
    return [self trashFileURL:fileURL resultItemURL:nil];
}
+ (BOOL)trashFileURL:(NSURL *)fileURL resultItemURL:(NSURL * _Nullable)outResultingURL {
    NSError *error;
    if ([[NSFileManager defaultManager] trashItemAtURL:fileURL resultingItemURL:&outResultingURL error:&error]) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"%@ 已经被移动到废纸篓", fileURL.path.lastPathComponent];
        return YES;
    } else {
        [[MUBLogManager defaultManager] addErrorLogWithFormat:@"移动文件 %@ 到废纸篓时发生错误: %@", fileURL.path.lastPathComponent, [error localizedDescription]];
        return NO;
    }
}
+ (BOOL)trashItemAtURL:(NSURL *)url resultingItemURL:(NSURL * _Nullable * _Nullable)outResultingURL error:(NSError **)error {
    return [[NSFileManager defaultManager] trashItemAtURL:url resultingItemURL:outResultingURL error:error];
}
+ (void)trashFilePaths:(NSArray<NSString *> *)filePaths {
    [self trashFileURLs:[self fileURLsFromFilePaths:filePaths]];
}
+ (void)trashFileURLs:(NSArray<NSURL *> *)fileURLs {
    [[NSWorkspace sharedWorkspace] recycleURLs:fileURLs completionHandler:^(NSDictionary<NSURL *,NSURL *> * _Nonnull newURLs, NSError * _Nullable error) {
        if (error) {
            [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"文件移动到废纸篓发生错误: %@", [error localizedDescription]];
        } else {
            [[MUBLogManager defaultManager] addErrorLogWithFormat:@"文件移动到废纸篓成功"];
        }
    }];
}

#pragma mark - Move
+ (void)moveItemFromPath:(NSString *)fromPath toPath:(NSString *)toPath {
    NSError *error;
    if (![[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:&error]) {
        [[MUBLogManager defaultManager] addErrorLogWithFormat:@"移动文件 %@ 时发生错误: %@", fromPath, [error localizedDescription]];
    }
}
+ (void)moveItemFromURL:(NSURL *)fromURL toDestURL:(NSURL *)toURL {
    NSError *error;
    if (![[NSFileManager defaultManager] moveItemAtURL:fromURL toURL:toURL error:&error]) {
        [[MUBLogManager defaultManager] addErrorLogWithFormat:@"移动文件 %@ 时发生错误: %@", fromURL.path, [error localizedDescription]];
    }
}
+ (void)moveItemFromPath:(NSString *)fromPath toPath:(NSString *)toPath error:(NSError **)error {
    [[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:error];
}
+ (void)moveItemFromURL:(NSURL *)fromURL toURL:(NSURL *)toURL error:(NSError **)error {
    [[NSFileManager defaultManager] moveItemAtURL:fromURL toURL:toURL error:error];
}

#pragma mark - File Path
+ (NSArray<NSString *> *)filePathsInFolder:(NSString *)folderPath {
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    
    for (NSString *content in contents) {
        if ([self fileShouldIgnore:content]) {
            continue;
        }
        
        NSString *filePath = [folderPath stringByAppendingPathComponent:content];
        BOOL folderFlag = YES;
        [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&folderFlag];
        
        if (!folderFlag) {
            [results addObject:filePath];
        }
    }
    
    return [results copy];
}
+ (NSArray<NSString *> *)filePathsInFolder:(NSString *)folderPath extensions:(NSArray<NSString *> *)extensions {
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    
    for (NSString *extension in extensions) {
        NSArray *filteredContents = [contents filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString * _Nonnull content, NSDictionary<NSString *,id> * _Nullable bindings) {
            return [content.pathExtension caseInsensitiveCompare:extension] == NSOrderedSame;
        }]];
        for (NSString *content in filteredContents) {
            NSString *filePath = [folderPath stringByAppendingPathComponent:content];
            BOOL folderFlag = YES;
            [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&folderFlag];
            
            if (!folderFlag) {
                [results addObject:filePath];
            }
        }
    }
    
    return [results copy];
}
+ (NSArray<NSString *> *)folderPathsInFolder:(NSString *)folderPath {
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    
    for (NSString *content in contents) {
        NSString *folder = [folderPath stringByAppendingPathComponent:content];
        BOOL folderFlag = YES;
        [[NSFileManager defaultManager] fileExistsAtPath:folder isDirectory:&folderFlag];
        
        if (folderFlag) {
            [results addObject:folder];
        }
    }
    
    return [results copy];
}
+ (NSArray<NSString *> *)contentPathsInFolder:(NSString *)folderPath {
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    return [contents bk_map:^id(NSString *obj) {
        return [folderPath stringByAppendingPathComponent:obj];
    }];
}
+ (NSArray<NSString *> *)allFilePathsInFolder:(NSString *)folderPath {
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    NSArray *contents = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    
    for (NSString *content in contents) {
        if ([self fileShouldIgnore:content]) {
            continue;
        }
        
        NSString *filePath = [folderPath stringByAppendingPathComponent:content];
        BOOL folderFlag = YES;
        [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&folderFlag];
        
        if (!folderFlag) {
            [results addObject:filePath];
        }
    }
    
    return [results copy];
}
+ (NSArray<NSString *> *)allFilePathsInFolder:(NSString *)folderPath extensions:(NSArray<NSString *> *)extensions {
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    NSArray *contents = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    
    for (NSString *extension in extensions) {
        NSArray *filteredContents = [contents filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString * _Nonnull content, NSDictionary<NSString *,id> * _Nullable bindings) {
            return [content.pathExtension caseInsensitiveCompare:extension] == NSOrderedSame;
        }]];
        for (NSString *content in filteredContents) {
            NSString *filePath = [folderPath stringByAppendingPathComponent:content];
            BOOL folderFlag = YES;
            [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&folderFlag];
            
            if (!folderFlag) {
                [results addObject:filePath];
            }
        }
    }
    
    return [results copy];
}
+ (NSArray<NSString *> *)allFolderPathInFolder:(NSString *)folderPath {
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    NSArray *contents = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    
    for (NSString *content in contents) {
        NSString *folder = [folderPath stringByAppendingPathComponent:content];
        BOOL folderFlag = YES;
        [[NSFileManager defaultManager] fileExistsAtPath:folder isDirectory:&folderFlag];
        
        if (folderFlag) {
            [results addObject:folder];
        }
    }
    
    return [results copy];
}
+ (NSArray<NSString *> *)allContentPathsInFolder:(NSString *)folderPath {
    NSArray *contents = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    return [contents bk_map:^id(NSString *obj) {
        return [folderPath stringByAppendingPathComponent:obj];
    }];
}

#pragma mark - Attributes
+ (NSDictionary *)allAttributesOfItemAtPath:(NSString *)path {
    NSError *error;
    NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
    return [NSDictionary dictionaryWithDictionary:dict];
}
+ (id)attribute:(NSString *)attribute ofItemAtPath:(NSString *)path {
    return [self allAttributesOfItemAtPath:path][attribute];
}

#pragma mark - Check
+ (BOOL)fileExistsAtPath:(NSString *)contentPath {
    return [[NSFileManager defaultManager] fileExistsAtPath:contentPath];
}
+ (BOOL)contentIsFolderAtPath:(NSString *)contentPath {
    BOOL folderFlag = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:contentPath isDirectory:&folderFlag];
    return folderFlag;
}
+ (BOOL)isEmptyFolderAtPath:(NSString *)folderPath {
    return [self contentPathsInFolder:folderPath].count == 0;
}

#pragma mark - Panel
+ (NSString *)pathFromOpenPanelURL:(NSURL *)URL {
    NSString *path = URL.absoluteString;
    path = [path stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    path = [path stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    path = [path stringByRemovingPercentEncoding];
    
    return path;
}

#pragma mark - Tool
+ (NSURL *)fileURLFromFilePath:(NSString *)filePath {
    return [NSURL fileURLWithPath:filePath];
}
+ (NSString *)filePathFromFileURL:(NSURL *)fileURL {
    return fileURL.path;
}
+ (NSArray<NSURL *> *)fileURLsFromFilePaths:(NSArray<NSString *> *)filePaths {
    return [filePaths bk_map:^id(NSString *obj) {
        return [NSURL fileURLWithPath:obj];
    }];
}
+ (NSArray<NSString *> *)filePathsFromFileURLs:(NSArray<NSURL *> *)fileURLs {
    return [fileURLs bk_map:^id(NSURL *obj) {
        return obj.path;
    }];
}
+ (BOOL)fileShouldIgnore:(NSString *)fileName {
    if ([fileName hasSuffix:@"DS_Store"]) {
        return YES;
    }
    
    return NO;;
}

@end
