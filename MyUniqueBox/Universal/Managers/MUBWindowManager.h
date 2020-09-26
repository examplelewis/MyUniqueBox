//
//  MUBWindowManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/26.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUBWindowController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MUBWindowManager : NSObject

#pragma mark - Lifecycle
+ (instancetype)defaultManager;

- (void)showWindowController:(MUBWindowController *)windowController;
- (void)closeWindowController:(MUBWindowController *)windowController;

@end

NS_ASSUME_NONNULL_END
