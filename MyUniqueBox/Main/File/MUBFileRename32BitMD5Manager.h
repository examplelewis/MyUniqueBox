//
//  MUBFileRename32BitMD5Manager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/16.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MUBFileRename32BitMD5ByType) {
    MUBFileRename32BitMD5ByTypeByFolder,
    MUBFileRename32BitMD5ByTypeByFile,
};

@interface MUBFileRename32BitMD5Manager : NSObject

- (void)showOpenPanelWithByType:(MUBFileRename32BitMD5ByType)byType;

@end

NS_ASSUME_NONNULL_END
