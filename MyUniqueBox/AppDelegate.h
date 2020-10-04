//
//  AppDelegate.h
//  MyUniqueBox
//
//  Created by 龚宇 on 2020/9/11.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSMenuItem *downloadRootMenuItem;

- (void)proceedMenuItemPressingWithTag:(NSInteger)tag;

@end

