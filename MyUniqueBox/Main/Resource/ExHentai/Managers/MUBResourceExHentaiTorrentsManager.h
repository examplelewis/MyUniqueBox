//
//  MUBResourceExHentaiTorrentsManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/10/02.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MUBResourceExHentaiTorrentsManager;

@protocol MUBResourceExHentaiTorrentsDelegate <NSObject>

@optional
- (void)manager:(MUBResourceExHentaiTorrentsManager *)manager didGetAllTorrentURLs:(NSArray<NSString *> *)URLs renameInfo:(NSDictionary *)renameInfo error:(NSError * _Nullable)error;

@end

@interface MUBResourceExHentaiTorrentsManager : NSObject

@property (weak) id<MUBResourceExHentaiTorrentsDelegate> delegate;

#pragma mark - Lifecycle
+ (instancetype)managerWithURLs:(NSArray *)URLs;

- (void)start;

@end

NS_ASSUME_NONNULL_END
