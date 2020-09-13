//
//  ViewController.m
//  MyUniqueBox
//
//  Created by 龚宇 on 2020/9/11.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)viewDidAppear {
    [super viewDidAppear];
    
    [[MUBUIManager defaultManager] setup];
    
    [[NSApplication sharedApplication].mainWindow makeFirstResponder:self.inputTextView]; // 设置组件为第一响应
}
- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

#pragma mark - IBAction
- (IBAction)exportButtonDidPress:(NSButton *)sender {
    NSString *input = self.inputTextView.string;
    if (input.length > 0) {
        [input exportToPath:@"/Users/Mercury/Downloads/Input.txt"];
    } else {
        [[MUBLogManager defaultManager] addDefaultLogWithBehavior:MUBLogBehaviorOnViewTimeAppend format:@"没有可导出的输入"];
    }
}
- (IBAction)tempButtonDidPress:(NSButton *)sender {
    
}
- (IBAction)cleanButtonDidPress:(NSButton *)sender {
    [[MUBLogManager defaultManager] clean];
}

@end
