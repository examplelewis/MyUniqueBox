//
//  MUBFileExtractTypeFileManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/16.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBFileExtractTypeFileManager.h"

@interface MUBFileExtractTypeFileManager ()

@property (copy) NSArray *types;

@end

@implementation MUBFileExtractTypeFileManager

- (instancetype)initWithTypes:(nullable id)types {
    self = [super init];
    if (self) {
        if ([types isKindOfClass:[NSArray class]] && ((NSArray *)types).count > 0) {
            self.types = (NSArray *)types;
        } else if ([types isKindOfClass:[NSString class]] && ((NSString *)types).length > 0) {
            self.types = [self extractCharactersFromString:(NSString *)types];
        } else {
            self.types = [self extractCharactersFromString:[MUBUIManager defaultManager].viewController.inputTextView.string];
        }
        
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"获取到 %ld 个文件类型:\n%@", self.types.count, [self.types componentsJoinedByString:@", "]];
    }
    
    return self;
}

- (void)showOpenPanel {
    if (!self.types.isNotEmpty) {
        [[MUBLogManager defaultManager] addWarningLogWithFormat:MUBWarningNoneContentFoundInInputTextView];
        return;
    }
    
    [MUBOpenPanelManager showOpenPanelOnMainWindowWithBehavior:MUBOpenPanelBehaviorSingleDir message:@"请选择需要提取的根文件夹" handler:^(NSOpenPanel *openPanel, NSModalResponse result) {
        if (result == NSModalResponseOK) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *path = [MUBFileManager pathFromOpenPanelURL:openPanel.URLs.firstObject];
                [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"已选择的根目录：%@", path];
                
                [self _extractWithRootFolderPath:path];
            });
        }
    }];
}
- (void)_extractWithRootFolderPath:(NSString *)rootFolderPath {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"提取 %@ 类型的文件，流程开始", [self.types componentsJoinedByString:@", "]];
    NSString *types = [self.types componentsJoinedByString:@" "];
    
    NSArray *filePaths = [MUBFileManager allFilePathsInFolder:rootFolderPath];
    for (NSInteger i = 0; i < filePaths.count; i++) {
        NSString *filePath = filePaths[i];
        if ([self.types indexOfObjectPassingTest:^BOOL(NSString * _Nonnull type, NSUInteger idx, BOOL * _Nonnull stop) {
            return [filePath.pathExtension caseInsensitiveCompare:type] == NSOrderedSame;
        }] == NSNotFound) {
            continue;
        }
        
        NSString *targetRootFolderName = [NSString stringWithFormat:@"%@ 提取 %@", rootFolderPath.lastPathComponent, types];
        NSString *targetRootFolderPath = [rootFolderPath.stringByDeletingLastPathComponent stringByAppendingPathComponent:targetRootFolderName];
        // 如果文件夹的路径后没有 /，那就补一个
        if (![targetRootFolderPath hasSuffix:@"/"]) {
            targetRootFolderPath = [targetRootFolderPath stringByAppendingString:@"/"];
        }
        NSString *targetFilePath = [filePath stringByReplacingOccurrencesOfString:rootFolderPath withString:targetRootFolderPath];
        NSString *targetFolderPath = targetFilePath.stringByDeletingLastPathComponent;
        
        if (![MUBFileManager fileExistsAtPath:targetFolderPath]) {
            [MUBFileManager createFolderAtPath:targetFolderPath];
        }
        [MUBFileManager moveItemFromPath:filePath toPath:targetFilePath];
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"\n提取前：\t%@\n提取后：\t%@", filePath, targetFilePath];
    }
    
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"提取 %@ 类型的文件，流程结束", [self.types componentsJoinedByString:@", "]];
}


#pragma mark - Tool
- (NSArray *)extractCharactersFromString:(NSString *)typeStr {
    if (typeStr.length == 0) {
        return @[];
    }
    
    NSArray *types = [typeStr componentsSeparatedByString:@" "];
    // 去除重复的字符
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:types];
    types = orderedSet.array;
    // 去除特定的字符
    NSArray *uselessChars = @[@""];
    types = [types filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString * _Nullable typeStr, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [uselessChars indexOfObject:typeStr] == NSNotFound;
    }]];
    
    return types;
}

@end
