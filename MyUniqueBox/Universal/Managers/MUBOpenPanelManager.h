//
//  MUBOpenPanelManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MUBOpenPanelBehavior) {
    MUBOpenPanelBehaviorNone            = 0,
    MUBOpenPanelBehaviorChooseDir       = 1 << 0,
    MUBOpenPanelBehaviorChooseFile      = 1 << 1,
    MUBOpenPanelBehaviorCreateDir       = 1 << 2,
    MUBOpenPanelBehaviorMultiple        = 1 << 3,
    MUBOpenPanelBehaviorShowHidden      = 1 << 3,
    
    MUBOpenPanelBehaviorSingleDir       = MUBOpenPanelBehaviorChooseDir,
    MUBOpenPanelBehaviorSingleFile      = MUBOpenPanelBehaviorChooseFile,
    MUBOpenPanelBehaviorSingleContent   = MUBOpenPanelBehaviorChooseDir | MUBOpenPanelBehaviorChooseFile,
    MUBOpenPanelBehaviorMultipleDir     = MUBOpenPanelBehaviorChooseDir | MUBOpenPanelBehaviorMultiple,
    MUBOpenPanelBehaviorMultipleFile    = MUBOpenPanelBehaviorChooseFile | MUBOpenPanelBehaviorMultiple,
    MUBOpenPanelBehaviorMultipleContent = MUBOpenPanelBehaviorChooseDir | MUBOpenPanelBehaviorChooseFile | MUBOpenPanelBehaviorMultiple,
};

@interface MUBOpenPanelManager : NSObject

+ (void)showOpenPanelOnMainWindowWithBehavior:(MUBOpenPanelBehavior)behavior message:(NSString *)message handler:(void (^)(NSOpenPanel *openPanel, NSModalResponse result))handler;
+ (void)showOpenPanelOnKeyWindowWithBehavior:(MUBOpenPanelBehavior)behavior message:(NSString *)message handler:(void (^)(NSOpenPanel *openPanel, NSModalResponse result))handler;
+ (void)showOpenPanelOnMainWindowWithBehavior:(MUBOpenPanelBehavior)behavior message:(NSString *)message prompt:(NSString *)prompt handler:(void (^)(NSOpenPanel *openPanel, NSModalResponse result))handler;
+ (void)showOpenPanelOnKeyWindowWithBehavior:(MUBOpenPanelBehavior)behavior message:(NSString *)message prompt:(NSString *)prompt handler:(void (^)(NSOpenPanel *openPanel, NSModalResponse result))handler;

+ (void)showOpenPanelOnWindow:(NSWindow *)window behavior:(MUBOpenPanelBehavior)behavior message:(NSString *)message prompt:(NSString *)prompt handler:(void (^)(NSOpenPanel *openPanel, NSModalResponse result))handler;

@end

NS_ASSUME_NONNULL_END
