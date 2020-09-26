//
//  MUBMenuItemDownloadManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/26.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBMenuItemDownloadManager.h"

static NSInteger const kDefaultTag = 4000000;

@implementation MUBMenuItemDownloadManager

+ (void)customMenuItemDidPress:(NSMenuItem *)sender {
    NSInteger type = (sender.tag - kDefaultTag) / 100;
    NSInteger action = (sender.tag - kDefaultTag) % 100;
    
}

@end
