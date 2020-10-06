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

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) WindowController *mainWindowController;
@property (nonatomic, strong) ViewController *viewController;

+ (instancetype)defaultManager;

- (void)scrollNewestLogVisible;
- (void)resetProgressIndicator;
- (void)resetProgressIndicatorMaxValue:(double)maxValue;
- (void)updateProgressIndicatorDoubleValue:(double)doubleValue;

@end

NS_ASSUME_NONNULL_END
