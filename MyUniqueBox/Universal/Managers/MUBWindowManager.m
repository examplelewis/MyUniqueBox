//
//  MUBWindowManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/26.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBWindowManager.h"

@interface MUBWindowManager ()

@property (strong) NSMutableArray *windows;
@property (strong) NSLock *lock;

@end

@implementation MUBWindowManager

#pragma mark - Lifecycle
+ (instancetype)defaultManager {
    static MUBWindowManager *defaultManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [[self alloc] init];
    });
    
    return defaultManager;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.lock = [NSLock new];
        self.windows = [NSMutableArray array];
    }
    
    return self;
}

- (void)showWindowController:(MUBWindowController *)windowController {
    [self.windows addObject:windowController];
    [windowController showWindow:nil];
}
- (void)closeWindowController:(MUBWindowController *)windowController {
    [self.windows removeObject:windowController];
}

@end
