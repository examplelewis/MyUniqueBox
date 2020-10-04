//
//  MUBResourceExHentaiCommentManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/10/04.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MUBResourceExHentaiCommentManager : NSObject

#pragma mark - Lifecycle
+ (instancetype)managerWithURLs:(NSArray *)URLs;

- (void)start;

@end

NS_ASSUME_NONNULL_END
