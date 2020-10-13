//
//  MUBResourceWeiboFavouriteManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/28.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MUBResourceWeiboFavouriteManager : NSObject

@property (assign) NSInteger maxFetchCount;

- (void)start;

#pragma mark - Tools
+ (void)outputFolderNameFromWeiboStatusText:(NSString * _Nullable)text;

@end

NS_ASSUME_NONNULL_END
