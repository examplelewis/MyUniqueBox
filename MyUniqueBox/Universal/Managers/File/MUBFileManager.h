//
//  MUBFileManager.h
//  MyComicView
//
//  Created by 龚宇 on 16/08/03.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MUBFileManager : NSObject

+ (instancetype)sharedManager;

- (BOOL)createFolderAtPathIfNotExist:(NSString *)folderPath;

- (BOOL)trashFileAtPath:(NSString *)filePath resultItemURL:(NSURL *)resultURL;
- (BOOL)trashFileAtURL:(NSURL *)fileURL resultItemURL:(NSURL *)resultURL;
- (void)trashFilesAtPaths:(NSArray<NSURL *> *)filePaths;

- (NSArray<NSURL *> *)convertFilePathsArrayToFileURLsArray:(NSArray<NSString *> *)paths;
- (NSArray<NSString *> *)convertFileURLsArrayToFilePathsArray:(NSArray<NSURL *> *)urls;

- (void)moveItemAtPath:(NSString *)oriPath toDestPath:(NSString *)destPath;
- (void)moveItemAtURL:(NSURL *)oriURL toDestURL:(NSURL *)destURL;
- (void)moveItemAtPath:(NSString *)oriPath toDestPath:(NSString *)destPath error:(NSError **)error;
- (void)moveItemAtURL:(NSURL *)oriURL toDestURL:(NSURL *)destURL error:(NSError **)error;

- (BOOL)isContentExistAtPath:(NSString *)contentPath;
- (BOOL)contentIsFolderAtPath:(NSString *)contentPath;

- (NSArray<NSString *> *)getFilePathsInFolder:(NSString *)folderPath;
- (NSArray<NSString *> *)getFilePathsInFolder:(NSString *)folderPath specificExtensions:(NSArray<NSString *> *)extensions;
- (NSArray<NSString *> *)getFolderPathsInFolder:(NSString *)folderPath;
- (NSArray<NSString *> *)getSubFilePathsInFolder:(NSString *)folderPath;
- (NSArray<NSString *> *)getSubFilePathsInFolder:(NSString *)folderPath specificExtensions:(NSArray<NSString *> *)extensions;
- (NSArray<NSString *> *)getSubFoldersPathInFolder:(NSString *)folderPath;

- (NSDictionary *)getAllAttributesOfItemAtPath:(NSString *)path;

- (id)getSpecificAttributeOfItemAtPath:(NSString *)path attribute:(NSString *)attribute;

- (BOOL)isEmptyFolderAtPath:(NSString *)folderPath;

@end
