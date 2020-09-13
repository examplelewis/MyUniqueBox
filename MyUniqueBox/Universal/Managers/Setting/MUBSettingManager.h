//
//  MUBSettingManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MUBSettingManager : NSObject

@property (strong, readonly) NSString *mainFolderPath;

+ (instancetype)defaultManager;

@end

NS_ASSUME_NONNULL_END
