//
//  MUBMenuItemToolPictureManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/22.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBMenuItemToolPictureManager.h"
#import "MUBMenuItemToolHeader.h"

@implementation MUBMenuItemToolPictureManager

+ (void)customMenuItemDidPress:(NSMenuItem *)sender {
    NSInteger type = (sender.tag - kMUBMenuItemToolTagOffset) / 10000;
    NSInteger section = (sender.tag - kMUBMenuItemToolTagOffset - type * 10000) / 100;
    NSInteger action = (sender.tag - kMUBMenuItemToolTagOffset) % 100;
    
    switch (section) {
        case 0: {
            switch (action) {
                case 1: {
                    
                }
                    break;
                case 2: {
                    
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
