//
//  MUBSettingManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBSettingManager.h"

static NSString * const MUBMainFolderPath = @"/Users/mercury/SynologyDrive/~同步文件夹/同步文档/MyUniqueBox";

@implementation MUBSettingManager

+ (instancetype)defaultManager {
    static MUBSettingManager *defaultManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [[self alloc] init];
    });
    
    return defaultManager;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        if ([MUBFileManager fileExistsAtPath:MUBMainFolderPath]) {
            _mainFolderPath = MUBMainFolderPath;
        } else {
            [MUBAlertManager showCriticalAlertOnMainWindowWithMessage:@"主文件夹不存在" info:[NSString stringWithFormat:@"需要检查:\n%@", MUBMainFolderPath] runModal:NO handler:nil];
        }
    }
    
    return self;
}

@end
