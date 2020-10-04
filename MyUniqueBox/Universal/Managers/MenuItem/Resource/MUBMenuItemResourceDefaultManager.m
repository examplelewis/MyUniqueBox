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
            NSString *URL = [MUBUIManager defaultManager].viewController.inputTextView.string;
            if (!URL.isNotEmpty) {
                [[MUBLogManager defaultManager] addWarningLogWithFormat:@"没有解析到有用的地址，请检查输入框的内容"];
                return;
            }
            
            if ([URL containsString:@"bcy.net"]) {
                
            } else if ([URL containsString:@"exhentai.org"] || [URL containsString:@"e-hentai.org"]) {
                [[MUBUIManager defaultManager].appDelegate proceedMenuItemPressingWithTag:1050001];
            } else if ([URL containsString:@"www.jdlingyu.com"]) {
                
            } else if ([URL containsString:@"www.pixiv.net"]) {
                if ([URL containsString:@"users"]) {
//                    [PixivMethod configMethod:1];
                } else if ([URL containsString:@"artworks"]) {
//                    [PixivMethod configMethod:2];
                } else {
//                    [PixivMethod configMethod:3];
                }
            } else if ([URL containsString:@"worldcosplay.net"]) {
                
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
