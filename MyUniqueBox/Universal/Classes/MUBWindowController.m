//
//  MUBWindowController.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/26.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBWindowController.h"

@interface MUBWindowController ()

@end

@implementation MUBWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
}

#pragma mark - NSWindowDelegate
- (BOOL)windowShouldClose:(NSWindow *)sender {
    [[MUBWindowManager defaultManager] closeWindowController:self];
    return YES;
}

@end
