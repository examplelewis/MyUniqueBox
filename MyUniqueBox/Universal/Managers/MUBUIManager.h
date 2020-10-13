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

#pragma mark - Lifecycle
+ (instancetype)defaultManager;

#pragma mark - Update
- (void)updateAppDelegate:(AppDelegate *)appDelegate;
- (void)updateMainWindowController:(WindowController *)mainWindowController;
- (void)updateViewController:(ViewController *)viewController;

#pragma mark - UI
- (void)scrollNewestLogVisible;
- (void)resetProgressIndicator;
- (void)resetProgressIndicatorMaxValue:(double)maxValue;
- (void)updateProgressIndicatorDoubleValue:(double)doubleValue;

@end

NS_ASSUME_NONNULL_END
