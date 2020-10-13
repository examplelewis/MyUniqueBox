//
//  MUBUIManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBUIManager.h"

@interface MUBUIManager ()

@property (assign) double progressIndicatorMaxValue;

@end

@implementation MUBUIManager

#pragma mark - Lifecycle
+ (instancetype)defaultManager {
    static MUBUIManager *defaultManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [[self alloc] init];
    });
    
    return defaultManager;
}

#pragma mark - Update
- (void)updateAppDelegate:(AppDelegate *)appDelegate {
    _appDelegate = appDelegate;
}
- (void)updateMainWindowController:(WindowController *)mainWindowController {
    _mainWindowController = mainWindowController;
}
- (void)updateViewController:(ViewController *)viewController {
    _viewController = viewController;
}

#pragma mark - UI
- (void)scrollNewestLogVisible {
    dispatch_main_async_safe((^{
        [self.viewController.logTextView scrollRangeToVisible:NSMakeRange(self.viewController.logTextView.string.length, 0)];
    }));
}
- (void)resetProgressIndicator {
    self.progressIndicatorMaxValue = 1.0f;
    
    dispatch_main_async_safe((^{
        self.viewController.progressIndicator.doubleValue = 0.0f;
        self.viewController.progressIndicator.maxValue = 1.0f;
        self.viewController.progressLabel.stringValue = @"0 / 0";
    }));
}
- (void)resetProgressIndicatorMaxValue:(double)maxValue {
    self.progressIndicatorMaxValue = maxValue;
    
    dispatch_main_async_safe((^{
        self.viewController.progressIndicator.doubleValue = 0.0f;
        self.viewController.progressIndicator.maxValue = maxValue;
        self.viewController.progressLabel.stringValue = [NSString stringWithFormat:@"0 / %.0f", maxValue];
    }));
}
- (void)updateProgressIndicatorDoubleValue:(double)doubleValue {
    dispatch_main_async_safe((^{
        self.viewController.progressIndicator.doubleValue = doubleValue;
        self.viewController.progressLabel.stringValue = [NSString stringWithFormat:@"%.0f / %.0f", doubleValue, self.progressIndicatorMaxValue];
    }));
}

@end
