//
//  MUBMenuItemManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBMenuItemManager.h"
#import "MUBMenuItemHeader.h"

@implementation MUBMenuItemManager

+ (void)customMenuItemDidPress:(NSMenuItem *)sender {
    switch (sender.tag / 1000000) {
        case 1: {
            
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
            
        }
            break;
        case 5: {
            
        }
            break;
        default:
            break;
    }
}

@end
