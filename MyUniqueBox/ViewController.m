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

// 去除文章中无用文字
- (void)removeUselessContentInArticle {
    BOOL firstLineIsTitle = YES; // 第一行是否是标题
    NSString *uselessContent = @" cool18.com";
    
    NSString *article = self.inputTextView.string; // 从输入框获取文本
    NSString *lineBreak = @"\r";
    NSArray *articleComponents = [article componentsSeparatedByString:lineBreak]; // 根据换行符分割
    // 如果不是根据\r分割那就根据\n分割
    if (articleComponents.count == 1) {
        lineBreak = @"\n";
        articleComponents = [article componentsSeparatedByString:lineBreak];
    }
    
    NSString *title;
    // 如果第一行是标题，那么先取出标题，再删除第一个数据
    if (firstLineIsTitle) {
        title = articleComponents.firstObject;
        articleComponents = [articleComponents subarrayWithRange:NSMakeRange(1, articleComponents.count - 1)];
    }
    
    NSString *output = [articleComponents componentsJoinedByString:@""]; // 去掉换行符后，拼成一行文字
    NSArray *cleanComponents = [output componentsSeparatedByString:uselessContent]; // 拼好的一行文字再根据 uselessContent 分割
    if (firstLineIsTitle) {
        cleanComponents = [@[title] arrayByAddingObjectsFromArray:cleanComponents]; // 如果原文本第一行是标题的话，分割完成后在第一个加上标题
    }
    output = [cleanComponents componentsJoinedByString:@"\n"]; // 将干净的内容按换行符合并

    self.logTextView.string = output;
}

// 孔雀海文件夹提取
- (void)extractKongquehaiFolder {
    NSString *rootFolder = @"/Volumes/Wait DS920/图包资源/20200905 下载/孔雀海/【合集67套】福利系列《少女映画》写真67套(包含高清视频和套图合辑)【17.27G】";
    NSArray *folderPaths = [MUBFileManager allFolderPathsInFolder:rootFolder];
    folderPaths = [folderPaths bk_select:^BOOL(NSString *obj) {
        return [obj.lastPathComponent hasPrefix:@"【"];
    }];
    for (NSString *folderPath in folderPaths) {
        NSString *newFolderPath = [rootFolder stringByAppendingPathComponent:folderPath.lastPathComponent];
        [MUBFileManager moveItemFromPath:folderPath toPath:newFolderPath];
    }
}

// 微博分享图片文件夹名称超过长度
- (void)substructWeiboFolderName {
    NSArray *folderPaths = [MUBFileManager folderPathsInFolder:@"/Users/Mercury/Downloads/ShareImages"];
    for (NSInteger i = 0; i < folderPaths.count; i++) {
        NSString *folderPath = folderPaths[i];
        if (folderPath.lastPathComponent.length < 100) {
            continue;
        } else {
            NSString *originFolderName = folderPath.lastPathComponent;
            NSString *newFolderName = [originFolderName substringToIndex:originFolderName.length - 18];
            newFolderName = [newFolderName substringToIndex:81];
            newFolderName = [newFolderName stringByAppendingFormat:@"+%@", [originFolderName componentsSeparatedByString:@"+"].lastObject];
            NSString *newFolderPath = [folderPath.stringByDeletingLastPathComponent stringByAppendingPathComponent:newFolderName];

            [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"\n重命名前：\t%@\n重命名后：\t%@", folderPath, newFolderPath];
            [MUBFileManager moveItemFromPath:folderPath toPath:newFolderPath];
        }
    }
}

// 去除文件夹名称中的Emoji表情
- (void)removeEmojiInFolderName {
    NSString *rootFolderPath = @"/Users/mercury/Downloads/未命名文件夹";
    NSArray *folderPaths = [MUBFileManager folderPathsInFolder:rootFolderPath];
    for (NSInteger i = 0; i < folderPaths.count; i++) {
        NSString *folderPath = folderPaths[i];
        NSString *folderName = folderPath.lastPathComponent;
        NSString *newFolderName = folderName.removeEmoji;
        
        if ([newFolderName isEqualToString:folderName]) {
            continue;
        }
        
        NSString *newFolderPath = [rootFolderPath stringByAppendingPathComponent:newFolderName];
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"\n重命名前：\t%@\n重命名后：\t%@", folderPath, newFolderPath];

        [MUBFileManager createFolderAtPath:newFolderPath];
        NSArray *filePaths = [MUBFileManager filePathsInFolder:folderPath];
        for (NSInteger j = 0; j < filePaths.count; j++) {
            NSString *filePath = filePaths[j];
            NSString *newFilePath = [newFolderPath stringByAppendingPathComponent:filePath.lastPathComponent];
            
            [MUBFileManager moveItemFromPath:filePath toPath:newFilePath];
        }
    }
}

// 去除文件路径中的Emoji表情
- (void)removeEmojiInFolderPath {
    NSArray *folderPaths = [MUBFileManager folderPathsInFolder:@"/Users/mercury/Downloads/微博图片"];
    for (NSInteger i = 0; i < folderPaths.count; i++) {
        NSString *folderPath = folderPaths[i];
        NSString *newFolderPath = [folderPath removeEmoji];
        if ([folderPath isEqualToString:newFolderPath]) {
            continue;
        }

        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"\n重命名前：\t%@\n重命名后：\t%@", folderPath, newFolderPath];

        [MUBFileManager createFolderAtPath:newFolderPath];
        NSArray *filePaths = [MUBFileManager filePathsInFolder:folderPath];
        for (NSInteger j = 0; j < filePaths.count; j++) {
            NSString *filePath = filePaths[j];
            NSString *newFilePath = [newFolderPath stringByAppendingPathComponent:filePath.lastPathComponent];

            [MUBFileManager moveItemFromPath:filePath toPath:newFilePath];
        }
    }
}

// 修改文件名适配Piwigo的上传
- (void)fixFolderNameForPiwigoUpload {
    NSArray *allFilePaths = [MUBFileManager allFilePathsInFolder:@"/Users/Mercury/Pictures/我的收藏/图片/ACG"];
    for (NSInteger i = 0; i < allFilePaths.count; i++) {
        NSString *filePath = allFilePaths[i];
        NSString *folderPath = filePath.stringByDeletingLastPathComponent;
        NSString *fileName = filePath.lastPathComponent;

        NSString *newFileName = fileName.copy;
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"&" withString:@"AND"];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"," withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"·" withString:@" "];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"･" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"`" withString:@" "];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"'" withString:@" "];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@":" withString:@" "];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"：" withString:@" "];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@";" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"#" withString:@""];

        newFileName = [newFileName stringByReplacingOccurrencesOfString:@" свет и тень" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"ｗ" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"Атаго" withString:@"ATAGO"];

        newFileName = [newFileName stringByReplacingOccurrencesOfString:@" - 무제" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@" 기록" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@" - 엘프 검사" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@" - 블러드 헌터" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"디바" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@" - 흑밥" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@" - ｴﾘﾁｬﾝ" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@" - 슼승님" withString:@""];

        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"❤" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"- _( ¦3」∠)_" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"(´・ω・｀)" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"ヽ(´▽｀)_" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"（＾ｖ＾）" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"₍₍ ◝( ω ◝) ⁾⁾" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@" - (☆´∀｀)" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@" - ｡ﾟ+.(･∀･)ﾟ+.ﾟ" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"₍₍ (◟ ω )◟ ⁾⁾" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@" - 🍧✨" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"•(_´ω｀_)" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"(_ ω _)" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"(-ω☆)" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"(_´ω )" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"〔ﾟДﾟ〕丿ｽｺﾞｲ！" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"（´∀｀）" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"(´∩ω∩｀)" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@" - 〜(꒪꒳꒪)〜" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@" - شهرازاد" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@" - ω" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@" - ＾ω＾ !" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@" - ٩(●ᴗ●)۶" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@" - (♥ω♥_)" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@" - ζζσ ᴗσ)ゞ　着替えちゃうﾖｰｿﾛｰ！" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"　_´ω )_" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"( ´ω )_ｲｶｶﾞですが" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"(´-ω- )" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"(_´∀｀)" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"ヾ(_ﾟοﾟ)ﾉｵｫｫ!!" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"(_´ω｀_)" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"ヽ(_´∀｀)" withString:@""];

        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"２" withString:@"2"];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"＆" withString:@"AND"];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"ｐ" withString:@"p"];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"Ｆ" withString:@"F"];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"Ｅ" withString:@"E"];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"Ｈ" withString:@"H"];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"３" withString:@"3"];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"Ｉ" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"６" withString:@"6"];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"Ο" withString:@"O"];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"７" withString:@"7"];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"４" withString:@"4"];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"１" withString:@"1"];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"＋" withString:@"+"];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"５" withString:@"5"];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"０" withString:@"0"];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"８" withString:@"8"];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"Ｘ" withString:@"X"];

        newFileName = [newFileName stringByReplacingOccurrencesOfString:@" ❤️❤️" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"💜" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@" - 🌸+゜" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"🌊" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"🔥" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"🍁" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@" 🏁" withString:@""];

        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"『" withString:@"["];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"』" withString:@"]"];

        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"%28" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"%29" withString:@""];

        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"ｻｧﾝ!!!" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"img%2F" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"（18.5 9）" withString:@""];

        newFileName = [newFileName stringByReplacingOccurrencesOfString:@" - (ฅ ’ω ’ฅ)​♥" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"／" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"＼" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"£¨478£©" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@" | 半次元-发现你身边的同好" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"|" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"(토미아)" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"+α" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"Χ" withString:@"X"];


        newFileName = [newFileName stringByReplacingOccurrencesOfString:@" - @$$$@" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@" - Scáthach Lingerie." withString:@""];


        newFileName = [newFileName stringByReplacingOccurrencesOfString:@" - 水着ｵﾙﾀさんがアイスを食べてるだけ" withString:@""];
        newFileName = [newFileName stringByReplacingOccurrencesOfString:@"◆" withString:@""];

//        if ([newFileName.stringByDeletingPathExtension hasSuffix:@" "]) {
//            newFileName = newFileName.stringByDeletingPathExtension;
//            newFileName = [newFileName substringToIndex:newFileName.length - 1];
//            newFileName = [newFileName stringByAppendingFormat:@".%@", filePath.pathExtension];
//        }

        if ([newFileName isEqualToString:fileName]) {
            continue;
        }

        NSString *newFilePath = [folderPath stringByAppendingPathComponent:newFileName];

        [MUBFileManager moveItemFromPath:filePath toPath:newFilePath];
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"\n重命名前：\t%@\n重命名后：\t%@", filePath, newFilePath];
    }
}

// 重命名文件夹以便满足群晖文件系统的长度限制(文件夹的名称长度 <99)
- (void)substructFolderNameForSynologyNASUpload {
    NSString *rootFolderPath = @"/Users/mercury/Downloads/未命名文件夹";
    NSArray *folderPaths = [MUBFileManager folderPathsInFolder:rootFolderPath];
    for (NSInteger i = 0; i < folderPaths.count; i++) {
        NSString *folderPath = folderPaths[i];
        NSString *folderName = folderPath.lastPathComponent;
        if (folderName.length < 99) {
            continue;
        }

        NSString *newFolderName = [folderName substringToIndex:folderName.length - 15];
        if (newFolderName.length < 84) {
            continue;
        }
        newFolderName = [newFolderName substringToIndex:84];
        newFolderName = [newFolderName stringByAppendingString:[folderName substringFromIndex:folderName.length - 15]];
        NSString *newFolderPath = [rootFolderPath stringByAppendingPathComponent:newFolderName];
        
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"\n重命名前：\t%@\n重命名后：\t%@", folderPath, newFolderPath];
        
        [MUBFileManager createFolderAtPath:newFolderPath];
        NSArray *filePaths = [MUBFileManager filePathsInFolder:folderPath];
        for (NSInteger j = 0; j < filePaths.count; j++) {
            NSString *filePath = filePaths[j];
            NSString *newFilePath = [newFolderPath stringByAppendingPathComponent:filePath.lastPathComponent];

            [MUBFileManager moveItemFromPath:filePath toPath:newFilePath];
        }
    }
}

@end
