//
//  MUBSQLiteExHentaiManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/10/04.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MUBSQLiteHeader.h"
#import "MUBResourceExHentaiModels.h"

NS_ASSUME_NONNULL_BEGIN

@interface MUBSQLiteExHentaiManager : NSObject

#pragma mark - Lifecycle
+ (instancetype)defaultManager;

#pragma mark - ExHentai
- (NSInteger)getDGIDWithExHentaiPageModel:(MUBResourceExHentaiPageModel *)model;

- (NSArray<MUBResourceExHentaiImageModel *> *)filteredExHentaiImageModelsFrom:(NSArray<MUBResourceExHentaiImageModel *> *)imageModels model:(MUBResourceExHentaiPageModel *)model;

- (void)insertExHentaiImageModels:(NSArray<MUBResourceExHentaiImageModel *> *)imageModels model:(MUBResourceExHentaiPageModel *)model downloadFolderPath:(NSString *)downloadFolderPath;

- (NSString *)pageURLWithGalleryID:(NSInteger)gid;

@end

NS_ASSUME_NONNULL_END
