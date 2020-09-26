//
//  MUBMenuItemToolManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/22.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBMenuItemToolManager.h"
#import "MUBMenuItemToolHeader.h"

#import "MUBMenuItemToolSystemManager.h"
#import "MUBMenuItemToolPictureManager.h"
#import "MUBMenuItemToolDigitalManager.h"

@implementation MUBMenuItemToolManager

+ (void)customMenuItemDidPress:(NSMenuItem *)sender {
    switch ((sender.tag - kMUBMenuItemToolTagOffset) / 10000) {
        case 1: {
            [MUBMenuItemToolSystemManager customMenuItemDidPress:sender];
        }
            break;
        case 2: {
            [MUBMenuItemToolPictureManager customMenuItemDidPress:sender];
        }
            break;
        case 3: {
            [MUBMenuItemToolDigitalManager customMenuItemDidPress:sender];
        }
            break;
        default:
            break;
    }
}

@end
