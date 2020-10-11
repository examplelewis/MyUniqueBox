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

+ (instancetype)defaultManager {
    static MUBUIManager *defaultManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [[self alloc] init];
    });
    
    return defaultManager;
}

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

- (AppDelegate *)appDelegate {
    if (!_appDelegate) {
        _appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    }

    return _appDelegate;
}
- (WindowController *)mainWindowController {
    if (!_mainWindowController) {
        _mainWindowController = (WindowController *)[NSApplication sharedApplication].mainWindow.windowController;
    }
    
    return _mainWindowController;
}
- (ViewController *)viewController {
    if (!_viewController) {
        _viewController = (ViewController *)self.mainWindowController.contentViewController;
    }
    
    return _viewController;
}

@end
