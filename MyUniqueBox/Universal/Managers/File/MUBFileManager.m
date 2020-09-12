//
//  MUBFileManager.m
//  MyComicView
//
//  Created by 龚宇 on 16/08/03.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "MUBFileManager.h"

@implementation MUBFileManager

#pragma mark - Lifecycle
+ (instancetype)sharedManager {
    static MUBFileManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

#pragma mark - Create
- (BOOL)createFolderAtPathIfNotExist:(NSString *)folderPath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:folderPath]) {
        return YES;
    } else {
        NSError *error;
        if ([[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            return YES;
        } else {
            [[MRBLogManager defaultManager] showLogWithFormat:@"创建文件夹：%@ 时失败，错误原因：\n%@", folderPath, [error localizedDescription]];
            return NO;
        }
    }
}

#pragma mark - Trash
- (BOOL)trashFileAtPath:(NSString *)filePath resultItemURL:(NSURL *)resultURL {
    NSError *error;
    if ([[NSFileManager defaultManager] trashItemAtURL:[NSURL fileURLWithPath:filePath] resultingItemURL:&resultURL error:&error]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"%@ 已经被删除", filePath.lastPathComponent];
        return YES;
    } else {
        [[MRBLogManager defaultManager] showLogWithFormat:@"删除文件 %@ 时出现错误：%@", filePath.lastPathComponent, [error localizedDescription]];
        return NO;
    }
}
- (BOOL)trashFileAtURL:(NSURL *)fileURL resultItemURL:(NSURL *)resultURL {
    NSError *error;
    if ([[NSFileManager defaultManager] trashItemAtURL:fileURL resultingItemURL:&resultURL error:&error]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"%@ 已经被删除", fileURL.path.lastPathComponent];
        return YES;
    } else {
        [[MRBLogManager defaultManager] showLogWithFormat:@"删除文件 %@ 时出现错误：%@", fileURL.path.lastPathComponent, [error localizedDescription]];
        return NO;
    }
}
- (void)trashFilesAtPaths:(NSArray<NSURL *> *)filePaths {
    [[NSWorkspace sharedWorkspace] recycleURLs:filePaths completionHandler:^(NSDictionary<NSURL *,NSURL *> * _Nonnull newURLs, NSError * _Nullable error) {
        if (error) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"文件移动到废纸篓失败：\n%@", [error localizedDescription]];
//#warning 这边应该加一个NSAlert
        } else {
            [[MRBLogManager defaultManager] showLogWithFormat:@"文件移动到废纸篓成功"];
        }
    }];
}

#pragma mark - Move
- (void)moveItemAtPath:(NSString *)oriPath toDestPath:(NSString *)destPath {
    NSError *error;
    if (![[NSFileManager defaultManager] moveItemAtPath:oriPath toPath:destPath error:&error]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"移动文件：%@ 时发生错误：%@", oriPath, [error localizedDescription]];
    }
}
- (void)moveItemAtURL:(NSURL *)oriURL toDestURL:(NSURL *)destURL {
    NSError *error;
    if (![[NSFileManager defaultManager] moveItemAtURL:oriURL toURL:destURL error:&error]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"移动文件：%@ 时发生错误：%@", oriURL.path, [error localizedDescription]];
    }
}
- (void)moveItemAtPath:(NSString *)oriPath toDestPath:(NSString *)destPath error:(NSError **)error {
    [[NSFileManager defaultManager] moveItemAtPath:oriPath toPath:destPath error:error];
}
- (void)moveItemAtURL:(NSURL *)oriURL toDestURL:(NSURL *)destURL error:(NSError **)error {
    [[NSFileManager defaultManager] moveItemAtURL:oriURL toURL:destURL error:error];
}



- (NSArray<NSString *> *)getFilePathsInFolder:(NSString *)folderPath {
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    
    for (NSString *fileName in contents) {
        if ([fileName hasSuffix:@"DS_Store"]) {
            continue;
        }
        
        NSString *folder = [folderPath stringByAppendingPathComponent:fileName];
        BOOL folderFlag = YES;
        [[NSFileManager defaultManager] fileExistsAtPath:folder isDirectory:&folderFlag];
        
        if (!folderFlag) {
            [results addObject:folder];
        }
    }
    
    return [NSArray arrayWithArray:results];
}
- (NSArray<NSString *> *)getFilePathsInFolder:(NSString *)folderPath specificExtensions:(NSArray<NSString *> *)extensions {
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    
    for (NSString *extension in extensions) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            return [[evaluatedObject pathExtension] caseInsensitiveCompare:extension] == NSOrderedSame;
        }];
        
        NSArray *filteredArray = [contents filteredArrayUsingPredicate:predicate];
        for (NSString *fileName in filteredArray) {
            NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
            
            [results addObject:filePath];
        }
    }
    
    return [NSArray arrayWithArray:results];
}
- (NSArray<NSString *> *)getFolderPathsInFolder:(NSString *)folderPath {
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
//    if (contents.count == 1) {
//        [[MRBLogManager defaultManager] showLogWithFormat:@"没有在：%@ 中获取到解压好的文件，已跳过", folderPath];
//        return nil;
//    }
    
    for (NSString *fileName in contents) {
        if ([fileName hasSuffix:@"DS_Store"]) {
            continue;
        }
        
        NSString *folder = [folderPath stringByAppendingPathComponent:fileName];
        BOOL folderFlag = YES;
        [[NSFileManager defaultManager] fileExistsAtPath:folder isDirectory:&folderFlag];
        
        if (folderFlag) {
            [results addObject:folder];
        }
    }
    
    return [NSArray arrayWithArray:results];
}
- (NSArray<NSString *> *)getSubFilePathsInFolder:(NSString *)folderPath {
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    NSArray *contents = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil]; //所有的文件【递归】
    
    for (NSString *fileName in contents) {
        if ([fileName hasSuffix:@"DS_Store"]) {
            continue;
        }
        
        NSString *folder = [folderPath stringByAppendingPathComponent:fileName];
        BOOL folderFlag = YES;
        [[NSFileManager defaultManager] fileExistsAtPath:folder isDirectory:&folderFlag];
        
        if (!folderFlag) {
            [results addObject:folder];
        }
    }
    
    return [NSArray arrayWithArray:results];
}
- (NSArray<NSString *> *)getSubFilePathsInFolder:(NSString *)folderPath specificExtensions:(NSArray<NSString *> *)extensions {
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    NSArray *contents = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil]; //所有的文件【递归】
    
    for (NSString *extension in extensions) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            return [[evaluatedObject pathExtension] caseInsensitiveCompare:extension] == NSOrderedSame;
        }];
        
        NSArray *filteredArray = [contents filteredArrayUsingPredicate:predicate];
        for (NSString *fileName in filteredArray) {
            NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
            
            [results addObject:filePath];
        }
    }
    
    return [NSArray arrayWithArray:results];
}
- (NSArray<NSString *> *)getSubFoldersPathInFolder:(NSString *)folderPath {
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    
    NSArray *subpaths = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil]; //所有的文件【递归】
    for (NSString *fileName in subpaths) {
        if ([fileName hasSuffix:@"DS_Store"]) {
            continue;
        }
        
        NSString *folder = [folderPath stringByAppendingPathComponent:fileName];
        BOOL folderFlag = YES;
        [[NSFileManager defaultManager] fileExistsAtPath:folder isDirectory:&folderFlag];
        
        if (folderFlag) {
            [results addObject:folder];
        }
    }
    
    return [NSArray arrayWithArray:results];
}

#pragma mark - Attributes
- (NSDictionary *)getAllAttributesOfItemAtPath:(NSString *)path {
    NSError *error;
    NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (id)getSpecificAttributeOfItemAtPath:(NSString *)path attribute:(NSString *)attribute {
    return [self getAllAttributesOfItemAtPath:path][attribute];
}

#pragma mark - Check
- (BOOL)isContentExistAtPath:(NSString *)contentPath {
    return [[NSFileManager defaultManager] fileExistsAtPath:contentPath];
}
- (BOOL)contentIsFolderAtPath:(NSString *)contentPath {
    BOOL isFolder = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:contentPath isDirectory:&isFolder];
    return isFolder;
}
- (BOOL)isEmptyFolderAtPath:(NSString *)folderPath {
    NSArray *contents = [self getFilePathsInFolder:folderPath];
    return contents.count == 0;
}

#pragma mark - Tool
- (NSArray<NSURL *> *)convertFilePathsArrayToFileURLsArray:(NSArray<NSString *> *)paths {
    NSMutableArray<NSURL *> *results = [NSMutableArray array];
    
    for (NSString *path in paths) {
        NSURL *url = [NSURL fileURLWithPath:path];
        [results addObject:url];
    }
    
    return [NSArray arrayWithArray:results];
}
- (NSArray<NSString *> *)convertFileURLsArrayToFilePathsArray:(NSArray<NSURL *> *)urls {
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    
    for (NSURL *url in urls) {
        NSString *path = url.path;
        [results addObject:path];
    }
    
    return [NSArray arrayWithArray:results];
}

@end
