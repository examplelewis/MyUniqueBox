//
//  MUBFileManager.h
//  MyComicView
//
//  Created by 龚宇 on 16/08/03.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MUBFileManager : NSObject

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Create
+ (BOOL)createFolderAtPath:(NSString *)folderPath;

#pragma mark - Open
+ (void)openContentAtPath:(NSString *)contentPath;
+ (void)openContentAtURL:(NSURL *)contentURL;

#pragma mark - Trash
+ (BOOL)trashFilePath:(NSString *)filePath;
+ (BOOL)trashFileURL:(NSURL *)fileURL;
+ (BOOL)trashFileURL:(NSURL *)fileURL resultItemURL:(NSURL * _Nullable)outResultingURL;
+ (BOOL)trashItemAtURL:(NSURL *)url resultingItemURL:(NSURL * _Nullable * _Nullable)outResultingURL error:(NSError **)error;
+ (void)trashFilePaths:(NSArray<NSString *> *)filePaths;
+ (void)trashFileURLs:(NSArray<NSURL *> *)fileURLs;

#pragma mark - Move
+ (void)moveItemFromPath:(NSString *)fromPath toPath:(NSString *)toPath;
+ (void)moveItemFromURL:(NSURL *)fromURL toDestURL:(NSURL *)toURL;
+ (void)moveItemFromPath:(NSString *)fromPath toPath:(NSString *)toPath error:(NSError **)error;
+ (void)moveItemFromURL:(NSURL *)fromURL toURL:(NSURL *)toURL error:(NSError **)error;

#pragma mark - File Path
+ (NSArray<NSString *> *)filePathsInFolder:(NSString *)folderPath;
+ (NSArray<NSString *> *)filePathsInFolder:(NSString *)folderPath extensions:(NSArray<NSString *> *)extensions;
+ (NSArray<NSString *> *)filePathsInFolder:(NSString *)folderPath withoutExtensions:(NSArray<NSString *> *)extensions;
+ (NSArray<NSString *> *)folderPathsInFolder:(NSString *)folderPath;
+ (NSArray<NSString *> *)contentPathsInFolder:(NSString *)folderPath;

+ (NSArray<NSString *> *)allFilePathsInFolder:(NSString *)folderPath;
+ (NSArray<NSString *> *)allFilePathsInFolder:(NSString *)folderPath extensions:(NSArray<NSString *> *)extensions;
+ (NSArray<NSString *> *)allFilePathsInFolder:(NSString *)folderPath withoutExtensions:(NSArray<NSString *> *)extensions;
+ (NSArray<NSString *> *)allFolderPathsInFolder:(NSString *)folderPath;
+ (NSArray<NSString *> *)allContentPathsInFolder:(NSString *)folderPath;

#pragma mark - Attributes
+ (NSDictionary *)allAttributesOfItemAtPath:(NSString *)path;
+ (id)attribute:(NSString *)attribute ofItemAtPath:(NSString *)path;

#pragma mark - Check
+ (BOOL)fileExistsAtPath:(NSString *)contentPath;
+ (BOOL)contentIsFolderAtPath:(NSString *)contentPath;
+ (BOOL)isEmptyFolderAtPath:(NSString *)folderPath;

#pragma mark - Panel
+ (NSString *)pathFromOpenPanelURL:(NSURL *)URL;

#pragma mark - Tool
+ (NSURL *)fileURLFromFilePath:(NSString *)filePath;
+ (NSString *)filePathFromFileURL:(NSURL *)fileURL;
+ (NSArray<NSURL *> *)fileURLsFromFilePaths:(NSArray<NSString *> *)filePaths;
+ (NSArray<NSString *> *)filePathsFromFileURLs:(NSArray<NSURL *> *)fileURLs;
+ (BOOL)fileShouldIgnore:(NSString *)fileName;
+ (NSArray<NSString *> *)filterReturnedContents:(NSArray<NSString *> *)contents;
+ (NSString *)removeSeparatorInPathComponentsAtContentPath:(NSString *)contentPath;

@end

NS_ASSUME_NONNULL_END
