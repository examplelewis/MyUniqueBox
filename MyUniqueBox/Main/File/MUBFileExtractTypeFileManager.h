//
//  MUBFileExtractTypeFileManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/16.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MUBFileExtractTypeFileManager : NSObject

- (instancetype)initWithTypes:(nullable id)types;

- (void)showOpenPanel;

@end

NS_ASSUME_NONNULL_END
