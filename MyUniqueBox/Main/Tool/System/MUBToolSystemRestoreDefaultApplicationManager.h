//
//  MUBToolSystemRestoreDefaultApplicationManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/22.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MUBToolSystemRestoreDefaultApplicationType) {
    MUBToolSystemRestoreDefaultApplicationTypeAudio,
    MUBToolSystemRestoreDefaultApplicationTypeImage,
    MUBToolSystemRestoreDefaultApplicationTypeVideo,
};

@interface MUBToolSystemRestoreDefaultApplicationManager : NSObject

+ (void)restoreWithType:(MUBToolSystemRestoreDefaultApplicationType)type applicationName:(NSString *)applicationName applicationBundleID:(NSString *)applicationBundleID;

@end

NS_ASSUME_NONNULL_END
