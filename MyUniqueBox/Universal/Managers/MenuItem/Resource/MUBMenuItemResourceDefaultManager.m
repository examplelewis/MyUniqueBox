//
//  MUBMenuItemResourceDefaultManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/28.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBMenuItemResourceDefaultManager.h"
#import "MUBMenuItemResourceHeader.h"

@implementation MUBMenuItemResourceDefaultManager

+ (void)customMenuItemDidPress:(NSMenuItem *)sender {
//    NSInteger type = (sender.tag - kMUBMenuItemResourceTagOffset) / 10000;
//    NSInteger section = (sender.tag - kMUBMenuItemResourceTagOffset - type * 10000) / 100;
    NSInteger action = (sender.tag - kMUBMenuItemResourceTagOffset) % 100;
    
    switch (action) {
        case 1: {
            NSURL *URL = [NSURL URLWithString:[MUBUIManager defaultManager].viewController.inputTextView.string];
            if (!URL) {
                [[MUBLogManager defaultManager] addWarningLogWithFormat:@"没有解析到有用的地址，请检查输入框的内容"];
                return;
            }
            
            if ([URL.host caseInsensitiveCompare:@"bcy.net"] == NSOrderedSame) {
                
            } else if ([URL.host caseInsensitiveCompare:@"exhentai.org"] == NSOrderedSame || [URL.host caseInsensitiveCompare:@"e-hentai.org"] == NSOrderedSame) {
                [[MUBUIManager defaultManager].appDelegate proceedMenuItemPressingWithTag:1050001];
            } else if ([URL.host caseInsensitiveCompare:@"www.jdlingyu.com"] == NSOrderedSame) {
                
            } else if ([URL.host caseInsensitiveCompare:@"www.pixiv.net"] == NSOrderedSame) {
                if ([URL.path hasPrefix:@"users"]) {
//                    [PixivMethod configMethod:1];
                } else if ([URL.path hasPrefix:@"artworks"]) {
//                    [PixivMethod configMethod:2];
                } else {
//                    [PixivMethod configMethod:3];
                }
            } else if ([URL.host caseInsensitiveCompare:@"worldcosplay.net"] == NSOrderedSame) {
                
            } else {
                [[MUBLogManager defaultManager] addWarningLogWithFormat:@"没有解析到有用的地址，请检查输入框的内容"];
            }
        }
            break;
        case 2: {
//            [MUBMenuItemToolPictureManager customMenuItemDidPress:sender];
        }
            break;
        default:
            break;
    }
}

@end
