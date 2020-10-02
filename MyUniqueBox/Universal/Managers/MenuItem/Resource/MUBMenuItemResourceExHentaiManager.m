//
//  MUBMenuItemResourceExHentaiManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/28.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBMenuItemResourceExHentaiManager.h"
#import "MUBMenuItemResourceHeader.h"

#import "MUBResourceExHentaiManager.h"

@implementation MUBMenuItemResourceExHentaiManager

+ (void)customMenuItemDidPress:(NSMenuItem *)sender {
    NSInteger type = (sender.tag - kMUBMenuItemResourceTagOffset) / 10000;
    NSInteger section = (sender.tag - kMUBMenuItemResourceTagOffset - type * 10000) / 100;
    NSInteger action = (sender.tag - kMUBMenuItemResourceTagOffset) % 100;
    
    switch (section) {
        case 0: {
            switch (action) {
                case 1: {
                    [[MUBLogManager defaultManager] reset];
                    [[MUBResourceExHentaiManager defaultManager] startWithType:MUBResourceExHentaiTypePages];
                }
                    break;
                case 2: {
                    [[MUBLogManager defaultManager] reset];
                    [[MUBResourceExHentaiManager defaultManager] startWithType:MUBResourceExHentaiTypeImages];
                }
                    break;
                case 3: {
                    [[MUBLogManager defaultManager] reset];
                    [[MUBResourceExHentaiManager defaultManager] startWithType:MUBResourceExHentaiTypeTorrents];
                }
                    break;
                case 4: {
                    [[MUBLogManager defaultManager] reset];
                    [[MUBResourceExHentaiManager defaultManager] startWithType:MUBResourceExHentaiTypePixivURLs];
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
