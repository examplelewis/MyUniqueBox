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
    
    [self.inputTextView setFont:[NSFont fontWithName:@"PingFangSC-Regular" size:12.0f]];
    [self.logTextView setFont:[NSFont fontWithName:@"PingFangSC-Regular" size:12.0f]];
    
    [[MUBUIManager defaultManager] updateViewController:self];
}
- (void)viewDidAppear {
    [super viewDidAppear];
    
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
    [[MUBLogManager defaultManager] addWarningLogWithFormat:@"临时方法执行失败，该方法没有实现"];
    
    // 微博分享图片文件夹名称超过长度
//    NSArray *folderPaths = [MUBFileManager folderPathsInFolder:@"/Users/Mercury/Downloads/ShareImages"];
//    for (NSInteger i = 0; i < folderPaths.count; i++) {
//        NSString *folderPath = folderPaths[i];
//        if (folderPath.lastPathComponent.length < 100) {
//            continue;
//        } else {
//            NSString *originFolderName = folderPath.lastPathComponent;
//            NSString *newFolderName = [originFolderName substringToIndex:originFolderName.length - 18];
//            newFolderName = [newFolderName substringToIndex:81];
//            newFolderName = [newFolderName stringByAppendingFormat:@"+%@", [originFolderName componentsSeparatedByString:@"+"].lastObject];
//            NSString *newFolderPath = [folderPath.stringByDeletingLastPathComponent stringByAppendingPathComponent:newFolderName];
//
//            [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"\n重命名前：\t%@\n重命名后：\t%@", folderPath, newFolderPath];
//            [MUBFileManager moveItemFromPath:folderPath toPath:newFolderPath];
//        }
//    }
    
    // 孔雀海文件夹提取
//    NSString *rootFolder = @"/Volumes/Wait DS920/图包资源/20200905 下载/孔雀海/【合集67套】福利系列《少女映画》写真67套(包含高清视频和套图合辑)【17.27G】";
//    NSArray *folderPaths = [MUBFileManager allFolderPathsInFolder:rootFolder];
//    folderPaths = [folderPaths bk_select:^BOOL(NSString *obj) {
//        return [obj.lastPathComponent hasPrefix:@"【"];
//    }];
//    for (NSString *folderPath in folderPaths) {
//        NSString *newFolderPath = [rootFolder stringByAppendingPathComponent:folderPath.lastPathComponent];
//        [MUBFileManager moveItemFromPath:folderPath toPath:newFolderPath];
//    }
    
    // 模板操作
//    NSString *content = self.inputTextView.string;
//    NSString *content = [NSString stringWithContentsOfFile:@"" encoding:NSUTF8StringEncoding error:nil];
//    NSArray *components = [content componentsSeparatedByString:@"\n"];
//    NSMutableArray *result = [NSMutableArray array];
//    for (NSString *string in components) {
//
//    }
//    self.outputTextView.string = [MRBUtilityManager convertResultArray:result];
}
- (IBAction)cleanButtonDidPress:(NSButton *)sender {
    [[MUBLogManager defaultManager] clean];
}

@end
