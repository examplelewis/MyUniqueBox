//
//  MUBHTTPExHentaiManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/10/02.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBHTTPManager.h"
#import "MUBResourceExHentaiModels.h"

NS_ASSUME_NONNULL_BEGIN

@interface MUBHTTPExHentaiManager : MUBHTTPManager

#pragma mark - Lifecycle
+ (instancetype)defaultManager;

- (void)getPostDetailWithPageURL:(NSString *)pageURL completionHandler:(nonnull void (^)(NSURLResponse * _Nonnull response, NSArray<MUBResourceExHentaiPageModel *> * _Nullable models, NSError * _Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
