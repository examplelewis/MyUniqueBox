//
//  MUBResourceExHentaiImagesManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/10/02.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MUBResourceExHentaiModels.h"

NS_ASSUME_NONNULL_BEGIN

@class MUBResourceExHentaiImagesManager;

@protocol MUBResourceExHentaiImagesDelegate <NSObject>

@optional
- (void)manager:(MUBResourceExHentaiImagesManager *)manager model:(MUBResourceExHentaiPageModel * _Nullable)model didGetAllImageModels:(NSArray<MUBResourceExHentaiImageModel *> *)imageModels error:(NSError * _Nullable)error;
- (void)manager:(MUBResourceExHentaiImagesManager *)manager model:(MUBResourceExHentaiPageModel * _Nullable)model didGetOneImageModel:(MUBResourceExHentaiImageModel *)imageModel error:(NSError * _Nullable)error;

@end

@interface MUBResourceExHentaiImagesManager : NSObject

@property (weak) id<MUBResourceExHentaiImagesDelegate> delegate;
@property (strong) MUBResourceExHentaiPageModel *model;

#pragma mark - Lifecycle
+ (instancetype)managerWithURLs:(NSArray *)URLs;

- (void)start;

@end

NS_ASSUME_NONNULL_END
