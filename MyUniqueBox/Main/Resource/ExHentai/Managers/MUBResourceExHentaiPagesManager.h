//
//  MUBResourceExHentaiPagesManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/10/02.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MUBResourceExHentaiPagesManager;
@class MUBResourceExHentaiPageModel;

@protocol MUBResourceExHentaiPagesDelegate <NSObject>

@optional
- (void)manager:(MUBResourceExHentaiPagesManager *)manager model:(MUBResourceExHentaiPageModel *)model didGetAllUrls:(NSArray<NSString *> *)urls error:(NSError * _Nullable)error;

@end

@interface MUBResourceExHentaiPagesManager : NSObject

@property (weak) id<MUBResourceExHentaiPagesDelegate> delegate;

#pragma mark - Lifecycle
+ (instancetype)managerFromPageURL:(NSString *)pageURL;

- (void)start;

@end

NS_ASSUME_NONNULL_END
