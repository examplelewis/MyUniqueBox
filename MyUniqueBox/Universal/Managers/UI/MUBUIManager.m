//
//  MUBUIManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBUIManager.h"

@implementation MUBUIManager

+ (instancetype)sharedManager {
    static MUBUIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}
- (void)setup {
    _appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    _mainWindowController = (WindowController *)[NSApplication sharedApplication].mainWindow.windowController;
    _viewController = (ViewController *)self.mainWindowController.contentViewController;
}

- (void)scrollNewestLogVisible {
    [self.viewController.logTextView scrollRangeToVisible:NSMakeRange(self.viewController.logTextView.string.length, 0)];
}



@end
