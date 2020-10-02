//
//  MUBResourceExHentaiImagesManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/10/02.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MUBResourceExHentaiImagesManager;
@class MUBResourceExHentaiPageModel;

@protocol MUBResourceExHentaiImagesDelegate <NSObject>

@optional
- (void)manager:(MUBResourceExHentaiImagesManager *)manager model:(MUBResourceExHentaiPageModel * _Nullable)model didGetAllImageURLs:(NSArray<NSString *> *)imageURLs error:(NSError * _Nullable)error;
- (void)manager:(MUBResourceExHentaiImagesManager *)manager model:(MUBResourceExHentaiPageModel * _Nullable)model didGetOneImageURL:(NSString *)imageURL error:(NSError * _Nullable)error;

@end

@interface MUBResourceExHentaiImagesManager : NSObject

@property (weak) id<MUBResourceExHentaiImagesDelegate> delegate;
@property (strong) MUBResourceExHentaiPageModel *model;

#pragma mark - Lifecycle
+ (instancetype)managerWithURLs:(NSArray *)URLs;

- (void)start;

@end

NS_ASSUME_NONNULL_END
