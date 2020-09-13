//
//  MUBAlertManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBAlertManager.h"

NSString * const MUBAlertReturnKeyEquivalent = @"\r";
NSString * const MUBAlertEscapeKeyEquivalent = @"\033";

@implementation MUBAlertManager

+ (void)showWarningAlertOnMainWindowWithMessage:(NSString *)message info:(NSString * _Nullable)info runModal:(BOOL)runModal handler:(void (^ _Nullable)(NSModalResponse))handler {
    [self showAlertWithStyle:NSAlertStyleWarning onWindow:[NSApplication sharedApplication].mainWindow message:message info:info runModal:runModal handler:handler];
}
+ (void)showInfomationalAlertOnMainWindowWithMessage:(NSString *)message info:(NSString * _Nullable)info runModal:(BOOL)runModal handler:(void (^ _Nullable)(NSModalResponse))handler {
    [self showAlertWithStyle:NSAlertStyleInformational onWindow:[NSApplication sharedApplication].mainWindow message:message info:info runModal:runModal handler:handler];
}
+ (void)showCriticalAlertOnMainWindowWithMessage:(NSString *)message info:(NSString * _Nullable)info runModal:(BOOL)runModal handler:(void (^ _Nullable)(NSModalResponse))handler {
    [self showAlertWithStyle:NSAlertStyleCritical onWindow:[NSApplication sharedApplication].mainWindow message:message info:info runModal:runModal handler:handler];
}

+ (void)showWarningAlertOnKeyWindowWithMessage:(NSString *)message info:(NSString * _Nullable)info runModal:(BOOL)runModal handler:(void (^ _Nullable)(NSModalResponse))handler {
    [self showAlertWithStyle:NSAlertStyleWarning onWindow:[NSApplication sharedApplication].keyWindow message:message info:info runModal:runModal handler:handler];
}
+ (void)showInfomationalAlertOnKeyWindowWithMessage:(NSString *)message info:(NSString * _Nullable)info runModal:(BOOL)runModal handler:(void (^ _Nullable)(NSModalResponse))handler {
    [self showAlertWithStyle:NSAlertStyleInformational onWindow:[NSApplication sharedApplication].keyWindow message:message info:info runModal:runModal handler:handler];
}
+ (void)showCriticalAlertOnKeyWindowWithMessage:(NSString *)message info:(NSString * _Nullable)info runModal:(BOOL)runModal handler:(void (^ _Nullable)(NSModalResponse))handler {
    [self showAlertWithStyle:NSAlertStyleCritical onWindow:[NSApplication sharedApplication].keyWindow message:message info:info runModal:runModal handler:handler];
}

+ (void)showAlertWithStyle:(NSAlertStyle)style onWindow:(NSWindow *)window message:(NSString *)message info:(NSString * _Nullable)info runModal:(BOOL)runModal handler:(void (^ _Nullable)(NSModalResponse))handler {
    MUBAlert *alert = [MUBAlertManager alertWithStyle:style message:message info:info];
    [alert addButtonWithTitles:@[@"好"] keyEquivalents:@[MUBAlertReturnKeyEquivalent]];
    
    if (runModal) {
        NSModalResponse response = [alert runModal];
        alert.response = response;
    } else {
        [alert beginSheetModalForWindow:window completionHandler:handler];
    }
}

+ (MUBAlert *)alertWithStyle:(NSAlertStyle)style message:(NSString *)message info:(NSString * _Nullable)info {
    MUBAlert *alert = [MUBAlert new];
    alert.alertStyle = style;
    alert.messageText = message;
    if (info.isNotEmpty) {
        alert.informativeText = info;
    }
    
    return alert;
}

@end
