//
//  MUBMenuItemResourceManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/28.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBMenuItemResourceManager.h"
#import "MUBMenuItemResourceHeader.h"

#import "MUBMenuItemResourceDefaultManager.h"
#import "MUBMenuItemResourceJDLingYuManager.h"
#import "MUBMenuItemResourceWeiboManager.h"
#import "MUBMenuItemResourceDeviantartManager.h"
#import "MUBMenuItemResourceExHentaiManager.h"
#import "MUBMenuItemResourcePixivManager.h"

@implementation MUBMenuItemResourceManager

+ (void)customMenuItemDidPress:(NSMenuItem *)sender {
    switch ((sender.tag - kMUBMenuItemResourceTagOffset) / 10000) {
        case 0: {
            [MUBMenuItemResourceDefaultManager customMenuItemDidPress:sender];
        }
            break;
        case 1: {
            // 半次元
        }
            break;
        case 2: {
            [MUBMenuItemResourceJDLingYuManager customMenuItemDidPress:sender];
        }
            break;
        case 3: {
            [MUBMenuItemResourceWeiboManager customMenuItemDidPress:sender];
        }
            break;
        case 4: {
            [MUBMenuItemResourceDeviantartManager customMenuItemDidPress:sender];
        }
            break;
        case 5: {
            [MUBMenuItemResourceExHentaiManager customMenuItemDidPress:sender];
        }
            break;
        case 6: {
            [MUBMenuItemResourcePixivManager customMenuItemDidPress:sender];
        }
            break;
        case 7: {
            // World Cosplay
        }
            break;
        default:
            break;
    }
}

@end
