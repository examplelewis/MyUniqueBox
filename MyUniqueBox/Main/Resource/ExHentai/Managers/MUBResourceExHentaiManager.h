//
//  MUBResourceExHentaiManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/10/02.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MUBResourceExHentaiType) {
    MUBResourceExHentaiTypePages,
    MUBResourceExHentaiTypeImages,
    MUBResourceExHentaiTypeTorrents,
    MUBResourceExHentaiTypePixivURLs,
};

@interface MUBResourceExHentaiManager : NSObject

#pragma mark - Lifecycle
+ (instancetype)defaultManager;

- (void)startWithType:(MUBResourceExHentaiType)type;

@end

NS_ASSUME_NONNULL_END
