//
//  NSArray+MUBAdd.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (MUBAdd)

- (BOOL)isEmpty;
- (BOOL)isNotEmpty;

- (NSString *)stringValue;

- (void)exportToPath:(NSString *)path;
- (void)exportToPlistPath:(NSString *)plistPath;

@end

NS_ASSUME_NONNULL_END
