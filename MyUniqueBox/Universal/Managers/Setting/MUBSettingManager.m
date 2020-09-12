//
//  MUBSettingManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBSettingManager.h"

static NSString * const MUBMainFolderPath = @"/Users/mercury/SynologyDrive/~同步文件夹/同步文档/MyResourceBox";

@implementation MUBSettingManager

+ (instancetype)sharedManager {
    static MUBSettingManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- (NSString *)mainFolderPath {
    
}

@end
