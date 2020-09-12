//
//  MUBUIManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "WindowController.h"
#import "ViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MUBUIManager : NSObject

@property (strong, readonly) AppDelegate *appDelegate;
@property (strong, readonly) WindowController *mainWindowController;
@property (strong, readonly) ViewController *viewController;

+ (instancetype)sharedManager;
- (void)setup;

- (void)scrollNewestLogVisible;

@end

NS_ASSUME_NONNULL_END
