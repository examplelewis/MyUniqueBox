//
//  MUBOpenPanelManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBOpenPanelManager.h"

@implementation MUBOpenPanelManager

+ (void)showOpenPanelOnMainWindowWithBehavior:(MUBOpenPanelBehavior)behavior message:(NSString *)message handler:(void (^)(NSOpenPanel *openPanel, NSModalResponse result))handler {
    [self showOpenPanelOnWindow:[NSApplication sharedApplication].mainWindow behavior:behavior message:message prompt:@"确定" handler:handler];
}
+ (void)showOpenPanelOnKeyWindowWithBehavior:(MUBOpenPanelBehavior)behavior message:(NSString *)message handler:(void (^)(NSOpenPanel *openPanel, NSModalResponse result))handler {
    [self showOpenPanelOnWindow:[NSApplication sharedApplication].keyWindow behavior:behavior message:message prompt:@"确定" handler:handler];
}
+ (void)showOpenPanelOnMainWindowWithBehavior:(MUBOpenPanelBehavior)behavior message:(NSString *)message prompt:(NSString *)prompt handler:(void (^)(NSOpenPanel *openPanel, NSModalResponse result))handler {
    [self showOpenPanelOnWindow:[NSApplication sharedApplication].mainWindow behavior:behavior message:message prompt:prompt handler:handler];
}
+ (void)showOpenPanelOnKeyWindowWithBehavior:(MUBOpenPanelBehavior)behavior message:(NSString *)message prompt:(NSString *)prompt handler:(void (^)(NSOpenPanel *openPanel, NSModalResponse result))handler {
    [self showOpenPanelOnWindow:[NSApplication sharedApplication].keyWindow behavior:behavior message:message prompt:prompt handler:handler];
}
+ (void)showOpenPanelOnWindow:(NSWindow *)window behavior:(MUBOpenPanelBehavior)behavior message:(NSString *)message prompt:(NSString *)prompt handler:(void (^)(NSOpenPanel *openPanel, NSModalResponse result))handler {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setMessage:message];
    panel.prompt = prompt;
    panel.canChooseDirectories = behavior & MUBOpenPanelBehaviorChooseDir;
    panel.canChooseFiles = behavior & MUBOpenPanelBehaviorChooseFile;
    panel.canCreateDirectories = NO;
    panel.allowsMultipleSelection = behavior & MUBOpenPanelBehaviorMultiple;
    
    [panel beginSheetModalForWindow:window completionHandler:^(NSModalResponse result) {
        if (handler) {
            handler(panel, result);
        }
    }];
}

@end
