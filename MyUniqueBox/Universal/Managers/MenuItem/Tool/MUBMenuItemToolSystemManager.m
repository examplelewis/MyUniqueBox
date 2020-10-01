//
//  MUBMenuItemToolSystemManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/22.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBMenuItemToolSystemManager.h"
#import "MUBMenuItemToolHeader.h"

#import "MUBToolSystemRestoreDefaultApplicationManager.h"
#import "MUBToolSystemWebArchiveUnarchivingManager.h"

@implementation MUBMenuItemToolSystemManager

+ (void)customMenuItemDidPress:(NSMenuItem *)sender {
    NSInteger type = (sender.tag - kMUBMenuItemToolTagOffset) / 10000;
    NSInteger section = (sender.tag - kMUBMenuItemToolTagOffset - type * 10000) / 100;
    NSInteger action = (sender.tag - kMUBMenuItemToolTagOffset) % 100;
    
    switch (section) {
        case 0: {
            switch (action) {
                case 1: {
                    [[MUBLogManager defaultManager] reset];
                    [[MUBToolSystemWebArchiveUnarchivingManager new] showOpenPanel];
                }
                    break;
                case 2: {
                    [[MUBLogManager defaultManager] reset];
                    [MUBToolSystemRestoreDefaultApplicationManager restoreWithType:MUBToolSystemRestoreDefaultApplicationTypeVideo applicationName:@"IINA" applicationBundleID:@"com.colliderli.iina"];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
}

@end
