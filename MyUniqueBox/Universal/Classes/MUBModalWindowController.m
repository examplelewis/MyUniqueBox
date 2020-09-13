//
//  MUBModalWindowController.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBModalWindowController.h"

@interface MUBModalWindowController ()

@end

@implementation MUBModalWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (BOOL)windowShouldClose:(NSWindow *)sender {
    [[NSApplication sharedApplication] stopModalWithCode:self.modalResponse];
    
    return YES;
}

@end
