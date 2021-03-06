//
//  MUBMenuItemManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBMenuItemManager.h"

#import "MUBMenuItemDownloadManager.h"
#import "MUBMenuItemFileManager.h"
#import "MUBMenuItemResourceManager.h"
#import "MUBMenuItemToolManager.h"

@implementation MUBMenuItemManager

+ (void)customMenuItemDidPress:(NSMenuItem *)sender {
    switch (sender.tag / 1000000) {
        case 1: {
            [MUBMenuItemResourceManager customMenuItemDidPress:sender];
        }
            break;
        case 2: {
            
        }
            break;
        case 3: {
            [MUBMenuItemFileManager customMenuItemDidPress:sender];
        }
            break;
        case 4: {
            [MUBMenuItemDownloadManager customMenuItemDidPress:sender];
        }
            break;
        case 5: {
            [MUBMenuItemToolManager customMenuItemDidPress:sender];
        }
            break;
        default:
            break;
    }
}

@end
