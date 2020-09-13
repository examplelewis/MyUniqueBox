//
//  MUBFileSearchCharactersManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBFileSearchCharactersManager.h"

@interface MUBFileSearchCharactersManager ()

@property (copy) NSArray *characters;
@property (strong) NSMutableArray *filePaths;

@end

@implementation MUBFileSearchCharactersManager

- (instancetype)initWithCharacters:(nullable id)characters {
    self = [super init];
    if (self) {
        self.filePaths = [NSMutableArray array];
        
        if ([characters isKindOfClass:[NSArray class]] && ((NSArray *)characters).count > 0) {
            self.characters = (NSArray *)characters;
        } else if ([characters isKindOfClass:[NSString class]] && ((NSString *)characters).length > 0) {
            self.characters = [self extractCharactersFromString:(NSString *)characters];
        } else {
            self.characters = [self extractCharactersFromString:[MUBUIManager defaultManager].viewController.inputTextView.string];
        }
        
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"获取到 %ld 个字符内容:\n%@", self.characters.count, [self.characters componentsJoinedByString:@" "]];
    }
    
    return self;
}

- (void)showOpenPanel {
    if (self.characters.isEmpty) {
        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"没有获得任何字符，请检查输入框"];
        return;
    }
    
    [MUBOpenPanelManager showOpenPanelOnMainWindowWithBehavior:MUBOpenPanelBehaviorSingleDir message:@"请选择需要查找的根目录" handler:^(NSOpenPanel *openPanel, NSModalResponse result) {
        if (result == NSModalResponseOK) {
            dispatch_async(dispatch_get_main_queue(), ^{
                DDLogInfo(@"已选择的根目录：%@", openPanel.URLs.firstObject);
                [self startWithRootFolder:[MUBFileManager filepathFromOpenPanelURL:openPanel.URLs.firstObject]];
            });
        }
    }];
}
- (void)startWithRootFolder:(NSString *)rootFolderPath {
    NSArray<NSString *> *allFilePaths = [MUBFileManager allFilePathsInFolder:rootFolderPath];
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"即将开始查找 %ld 个文件", allFilePaths.count];
    
    for (NSInteger i = 0; i < allFilePaths.count; i++) {
        BOOL found = NO;
        NSString *filePath = allFilePaths[i];
        NSMutableArray *filePathComponents = [filePath.pathComponents mutableCopy];
        
        // 去除包含 / 的路径
        [filePathComponents filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString * _Nullable charStr, NSDictionary<NSString *,id> * _Nullable bindings) {
            return ![charStr isEqualToString:@"/"];
        }]];
        
        if ([filePathComponents.lastObject hasPrefix:@"(C89) [AGOI亭 (三九呂)]"]) {
            NSLog(@"haha");
        }
        
        for (NSInteger j = 0; j < filePathComponents.count; j++) {
            for (NSInteger k = 0; k < self.characters.count; k++) {
                if ([filePathComponents[j] rangeOfString:self.characters[k]].location != NSNotFound) {
                    found = YES;
     
                    goto outer;
                }
            }
        }
    outer:;
        
        if (found) {
            [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"已查找到第 %ld 个文件, 文件名包含特定字符: %@", i + 1, filePath];
            [self.filePaths addObject:filePath];
        } else {
            [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"已查找到第 %ld 个文件, 文件名不包含特定字符", i + 1];
        }
    }
    
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"已经完成查找 %ld 个文件\n共找到 %ld 个包含特定字符的文件", allFilePaths.count, self.filePaths.count];
    
    if (self.filePaths.count > 0) {
//        [self.filePaths exportToPath:MRBFileOperationFindSpecificCharactersExportTXTPath];
    }
}

- (void)modifyFileNames {
    if (self.characters.count == 0) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"没有获得任何字符，请检查输入框"];
        return;
    }
    
//    if (![MUBFileManager fileExistsAtPath:MRBFileOperationFindSpecificCharactersExportTXTPath]) {
//        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"%@ 文件不存在，请检查", MRBFileOperationFindSpecificCharactersExportTXTPath];
//        return;
//    }
    
    NSError *error;
//    NSString *filePathsStr = [[NSString alloc] initWithContentsOfFile:MRBFileOperationFindSpecificCharactersExportTXTPath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
//        [[MUBLogManager defaultManager] addErrorLogWithFormat:@"读取 %@ 文件内的内容失败: %@", MRBFileOperationFindSpecificCharactersExportTXTPath, error.localizedDescription];
        return;
    }
    
//    NSArray *filePaths = [filePathsStr componentsSeparatedByString:@"\n"];
//    [[MRBLogManager defaultManager] showLogWithFormat:@"即将开始修改 %ld 个文件", filePaths.count];
    
//    for (NSInteger i = 0; i < filePaths.count; i++) {
//        NSString *filePath = filePaths[i];
//        // 如果文件不存在，那么可能是因为之前的操作把文件夹都改掉了
//        if (![[MRBFileManager defaultManager] isContentExistAtPath:filePath]) {
//            continue;
//        }
//        NSMutableArray *filePathComponents = [filePath.pathComponents mutableCopy];
//
//        // 去除包含 / 的路径
//        [filePathComponents filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString * _Nullable charStr, NSDictionary<NSString *,id> * _Nullable bindings) {
//            return ![charStr isEqualToString:@"/"];
//        }]];
//
//        for (NSInteger j = 0; j < filePathComponents.count; j++) {
//            for (NSInteger k = 0; k < self.characters.count; k++) {
//                if ([filePathComponents[j] rangeOfString:self.characters[k]].location != NSNotFound) {
//                    filePathComponents[j] = [filePathComponents[j] stringByReplacingOccurrencesOfString:self.characters[k] withString:@" "];
//                }
//            }
//        }
//
//        // 补上路径前的 /
//        NSString *newFilePath = [@"/" stringByAppendingString:[filePathComponents componentsJoinedByString:@"/"]];
//
//        [MUBFileManager moveItemFromPath:filePath toPath:newFilePath];
//        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"已修改第 %ld 个文件:\n%@\n%@", i + 1, filePath, newFilePath];
//    }
    
//    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"已经完成修改 %ld 个文件", filePaths.count];
//    [MUBFileManager trashFilePath:MRBFileOperationFindSpecificCharactersExportTXTPath];
}

#pragma mark - Tool
- (NSArray *)extractCharactersFromString:(NSString *)charStr {
    if (charStr.length == 0) {
        return @[];
    }
    
    NSArray *characters = [charStr componentsSeparatedByString:@" "];
    // 去除重复的字符
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:characters];
    characters = orderedSet.array;
    // 去除特定的字符
    NSArray *uselessChars = @[@""];
    characters = [characters filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString * _Nullable charStr, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [uselessChars indexOfObject:charStr] == NSNotFound;
    }]];
    
    return characters;
}

@end
