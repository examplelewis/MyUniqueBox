//
//  MUBMenuItemResourceJDLingYuManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/28.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBMenuItemResourceJDLingYuManager.h"
#import "MUBMenuItemResourceHeader.h"

@implementation MUBMenuItemResourceJDLingYuManager

+ (void)customMenuItemDidPress:(NSMenuItem *)sender {
    NSInteger type = (sender.tag - kMUBMenuItemResourceTagOffset) / 10000;
    NSInteger section = (sender.tag - kMUBMenuItemResourceTagOffset - type * 10000) / 100;
    NSInteger action = (sender.tag - kMUBMenuItemResourceTagOffset) % 100;
    
    switch (section) {
        case 0: {
            switch (action) {
                case 1: {
                    
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
