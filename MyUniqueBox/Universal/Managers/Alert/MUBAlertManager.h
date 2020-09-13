//
//  MUBAlertManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUBAlert.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const MUBAlertReturnKeyEquivalent;
extern NSString * const MUBAlertEscapeKeyEquivalent;

@interface MUBAlertManager : NSObject

+ (void)showWarningAlertOnMainWindowWithMessage:(NSString *)message info:(NSString * _Nullable)info runModal:(BOOL)runModal handler:(void (^ _Nullable)(NSModalResponse returnCode))handler;
+ (void)showInfomationalAlertOnMainWindowWithMessage:(NSString *)message info:(NSString * _Nullable)info runModal:(BOOL)runModal handler:(void (^ _Nullable)(NSModalResponse returnCode))handler;
+ (void)showCriticalAlertOnMainWindowWithMessage:(NSString *)message info:(NSString * _Nullable)info runModal:(BOOL)runModal handler:(void (^ _Nullable)(NSModalResponse returnCode))handler;

+ (void)showWarningAlertOnKeyWindowWithMessage:(NSString *)message info:(NSString * _Nullable)info runModal:(BOOL)runModal handler:(void (^ _Nullable)(NSModalResponse returnCode))handler;
+ (void)showInfomationalAlertOnKeyWindowWithMessage:(NSString *)message info:(NSString * _Nullable)info runModal:(BOOL)runModal handler:(void (^ _Nullable)(NSModalResponse returnCode))handler;
+ (void)showCriticalAlertOnKeyWindowWithMessage:(NSString *)message info:(NSString * _Nullable)info runModal:(BOOL)runModal handler:(void (^ _Nullable)(NSModalResponse returnCode))handler;

+ (void)showAlertWithStyle:(NSAlertStyle)style onWindow:(NSWindow *)window message:(NSString *)message info:(NSString * _Nullable)info runModal:(BOOL)runModal handler:(void (^ _Nullable)(NSModalResponse))handler;

+ (MUBAlert *)alertWithStyle:(NSAlertStyle)style message:(NSString *)message info:(NSString * _Nullable)info;

@end

NS_ASSUME_NONNULL_END
