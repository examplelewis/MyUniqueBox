//
//  MUBCookieManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 2020/9/12.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MUBCookieType) {
    MUBCookieTypeExHentai,
    MUBCookieTypeBCY,
    MUBCookieTypeWorldCosplay,
};

@interface MUBCookieManager : NSObject

#pragma mark - Lifecycle
+ (instancetype)managerWithType:(MUBCookieType)type;

- (void)writeCookies;
- (void)deleteCookieByName:(NSString *)name;
- (void)outputCookies;

@end

NS_ASSUME_NONNULL_END
