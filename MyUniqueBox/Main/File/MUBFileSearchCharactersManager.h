//
//  MUBFileSearchCharactersManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MUBFileSearchCharactersManager : NSObject

- (instancetype)initWithCharacters:(nullable id)characters;

- (void)showOpenPanel;
- (void)modifyFileNames;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
