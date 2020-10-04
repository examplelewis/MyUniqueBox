//
//  MUBResourceExHentaiCommentManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/10/04.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBResourceExHentaiCommentManager.h"
#import <hpple/TFHpple.h>

#import "MUBResourceExHentaiHeader.h"

@interface MUBResourceExHentaiCommentManager ()

@property (copy) NSArray *URLs;

@property (assign) NSInteger download;
@property (strong) NSMutableArray<NSString *> *pixivURLs; // 获取到的Pixiv链接
@property (strong) NSMutableArray<NSString *> *hasnotPixivURLs; // 没有获取到Pixiv链接的ExHentai链接
@property (strong) NSMutableArray *failures;
@property (copy) NSArray *existCount;

@end

@implementation MUBResourceExHentaiCommentManager

#pragma mark - Lifecycle
+ (instancetype)managerWithURLs:(NSArray *)URLs {
    MUBResourceExHentaiCommentManager *manager = [MUBResourceExHentaiCommentManager new];
    manager.URLs = URLs;
    [manager _readExistRecords];
    return manager;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.download = 0;
        self.pixivURLs = [NSMutableArray array];
        self.hasnotPixivURLs = [NSMutableArray array];
        self.failures = [NSMutableArray array];
    }
    
    return self;
}

#pragma mark - Configure
- (void)_readExistRecords {
    NSString *pixivURLsFilePath = [[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourceExHentaiSuccessCommentPixivURLsFilePath];
    NSString *hasnotPixivURLsFilePath = [[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourceExHentaiSuccessCommentHasnotPixivURLsFilePath];
    NSString *failuresFilePath = [[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourceExHentaiFailureCommentPixivURLsFilePath];
    
    NSInteger pixivURLsCount = 0;
    NSInteger hasnotPixivURLsCount = 0;
    NSInteger failuresCount = 0;
    
    if ([MUBFileManager fileExistsAtPath:pixivURLsFilePath]) {
        NSString *string = [[NSString alloc] initWithContentsOfFile:pixivURLsFilePath encoding:NSUTF8StringEncoding error:nil];
        [self.pixivURLs addObjectsFromArray:[string componentsSeparatedByString:@"\n"]];
        pixivURLsCount = self.pixivURLs.count;
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"从已存在的文件中读取到 %ld 条Pixiv链接记录", pixivURLsCount];
    }
    
    if ([MUBFileManager fileExistsAtPath:hasnotPixivURLsFilePath]) {
        NSString *string = [[NSString alloc] initWithContentsOfFile:hasnotPixivURLsFilePath encoding:NSUTF8StringEncoding error:nil];
        [self.hasnotPixivURLs addObjectsFromArray:[string componentsSeparatedByString:@"\n"]];
        hasnotPixivURLsCount = self.hasnotPixivURLs.count;
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"从已存在的文件中读取到 %ld 条未包含Pixiv链接的ExHentai链接记录", hasnotPixivURLsCount];
    }
    [self.hasnotPixivURLs addObjectsFromArray:self.URLs];
    
    if ([MUBFileManager fileExistsAtPath:failuresFilePath]) {
        NSString *string = [[NSString alloc] initWithContentsOfFile:failuresFilePath encoding:NSUTF8StringEncoding error:nil];
        [self.failures addObjectsFromArray:[string componentsSeparatedByString:@"\n"]];
        failuresCount = self.failures.count;
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"从已存在的文件中读取到 %ld 条下载失败的记录", failuresCount];
    }
    
    self.existCount = @[@(pixivURLsCount), @(hasnotPixivURLsCount), @(failuresCount)];
}

- (void)start {
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"获取评论中Pixiv链接, 流程开始"];
    [[MUBUIManager defaultManager] resetProgressIndicatorMaxValue: (double)self.URLs.count];
    
    for (NSInteger i = 0; i < self.URLs.count; i++) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.URLs[i]]
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:15.0f];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                [[MUBLogManager defaultManager] addErrorLogWithFormat:@"获取网页信息失败，原因：%@", error.localizedDescription];
                
                [self.failures addObject:self.URLs[i]];
                [self.failures exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourceExHentaiFailureCommentPixivURLsFilePath]];
            } else {
                TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
                
                // 评论地址 评论节点样式: <div class="c6" id="comment_0">Pixiv: https://www.pixiv.net/member.php?id=2141775</div>
                NSArray *divArray = [xpathParser searchWithXPathQuery:@"//div"];
                NSPredicate *divPredicate = [NSPredicate predicateWithBlock:^BOOL(TFHppleElement * _Nullable element, NSDictionary<NSString *,id> * _Nullable bindings) {
                    return [element.attributes[@"id"] hasPrefix:@"comment_"] && [element.attributes[@"class"] isEqualToString:@"c6"];
                }];
                NSArray *comments = [divArray filteredArrayUsingPredicate:divPredicate];
                NSArray *pixivURLs = [self _parsedURLsWithComments:comments host:@"www.pixiv.net"];
                if (pixivURLs.count > 0) {
                    [self.pixivURLs addObjectsFromArray:[pixivURLs valueForKeyPath:@"URL.absoluteString"]];
                    [self.hasnotPixivURLs removeObject:self.URLs[i]];
                } else {
                    // 如果抓取不到 pixiv 和 patreon 的地址，再尝试解析 Title 中的 Pixiv ID
                    NSArray *titleArray = [xpathParser searchWithXPathQuery:@"//h1"];
                    NSPredicate *h1Predicate = [NSPredicate predicateWithBlock:^BOOL(TFHppleElement * _Nullable element, NSDictionary<NSString *,id> * _Nullable bindings) {
                        return [element.attributes[@"id"] isEqualToString:@"gn"];
                    }];
                    NSArray *titles = [titleArray filteredArrayUsingPredicate:h1Predicate];
                    
                    NSArray *titleURLs = [self _parsedURLsFromTitles:titles];
                    if (titleURLs.count > 0) {
                        [self.pixivURLs addObjectsFromArray:titleURLs];
                        [self.hasnotPixivURLs removeObject:self.URLs[i]];
                    }
                }
                
                [self.pixivURLs exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourceExHentaiSuccessCommentPixivURLsFilePath]];
                [self.hasnotPixivURLs exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourceExHentaiSuccessCommentHasnotPixivURLsFilePath]];
            }
            
            [self _didFinishDownloadingOneWebpage];
        }];
        
        [task resume];
    }
}
- (NSArray *)_parsedURLsWithComments:(NSArray *)comments host:(NSString *)host {
    NSPredicate *rawPredicate = [NSPredicate predicateWithFormat:@"raw CONTAINS[cd] %@", host];
    NSArray *raws = [comments filteredArrayUsingPredicate:rawPredicate];
    if (raws.count == 0) {
        return @[];
    }
    
    TFHppleElement *elem = raws[0];
    NSPredicate *contentPredicate = [NSPredicate predicateWithFormat:@"content CONTAINS[cd] %@", host];
    NSArray *contents = [elem.children filteredArrayUsingPredicate:contentPredicate];
    if (contents.count == 0) {
        return @[];
    }
    
    NSString *content = ((TFHppleElement *)contents[0]).content;
    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    
    return [detector matchesInString:content options:kNilOptions range:NSMakeRange(0, content.length)];
}
- (NSArray *)_parsedURLsFromTitles:(NSArray *)titles {
    if (titles.count == 0) {
        return @[];
    }
    
    TFHppleElement *element = titles[0];
    if (element.children.count == 0) {
        return @[];
    }
    
    NSMutableArray *results = [NSMutableArray array];
    NSString *content = ((TFHppleElement *)element.children[0]).content;
    
    // 只有 Title 中包含 Pixiv，那么再去查找数字
    if ([content rangeOfString:@"pixiv" options:NSCaseInsensitiveSearch].location == NSNotFound) {
        return @[];
    }
    
    NSError *error = nil;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"\\d+" options:0 error:&error];
    NSArray *matches = [regex matchesInString:content options:0 range:NSMakeRange(0, content.length)];
    for (NSTextCheckingResult *match in matches) {
        NSString *strNumber = [content substringWithRange:match.range];
        [results addObject:[NSString stringWithFormat:@"https://www.pixiv.net/users/%@", strNumber]];
    }
    
    return [results copy];
}

- (void)_didFinishDownloadingOneWebpage {
    self.download += 1;
    [[MUBUIManager defaultManager] updateProgressIndicatorDoubleValue:(double)self.download];
    if (self.download != self.URLs.count) {
        return;
    }
    
    NSInteger beforePixivURLsCount = self.pixivURLs.count;
    NSOrderedSet *pixivURLsSet = [NSOrderedSet orderedSetWithArray:self.pixivURLs];
    self.pixivURLs = [NSMutableArray arrayWithArray:pixivURLsSet.array];
    if (beforePixivURLsCount != self.pixivURLs.count) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"成功获取到的 Pixiv 数据有 %ld 条重复", beforePixivURLsCount - self.pixivURLs.count];
    }
    if (self.pixivURLs.count > 0) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"本次流程成功获取到 %ld 条 Pixiv 数据，一共获取到 %ld 条", self.pixivURLs.count - [self.existCount[0] integerValue], self.pixivURLs.count];
    } else {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"没有获取到评论中的Pixiv地址"];
    }
    [self.pixivURLs exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourceExHentaiSuccessCommentPixivURLsFilePath]];
    
    NSInteger beforeHasnotPixivURLsCount = self.hasnotPixivURLs.count;
    NSOrderedSet *hasnotPixivURLsSet = [NSOrderedSet orderedSetWithArray:self.hasnotPixivURLs];
    self.hasnotPixivURLs = [NSMutableArray arrayWithArray:hasnotPixivURLsSet.array];
    if (beforeHasnotPixivURLsCount != self.hasnotPixivURLs.count) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"没有获取到 Pixiv 数据的 ExHentai 链接有 %ld 条重复", beforeHasnotPixivURLsCount - self.hasnotPixivURLs.count];
    }
    if (self.hasnotPixivURLs.count > 0) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"本次流程有 %ld 条没有获取到数据，一共有 %ld 条", self.hasnotPixivURLs.count - [self.existCount[1] integerValue], self.hasnotPixivURLs.count];
    }
    [self.hasnotPixivURLs exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourceExHentaiSuccessCommentHasnotPixivURLsFilePath]];
    
    NSInteger beforeFailuresCount = self.failures.count;
    NSOrderedSet *failuresSet = [NSOrderedSet orderedSetWithArray:self.failures];
    self.failures = [NSMutableArray arrayWithArray:failuresSet.array];
    if (beforeFailuresCount != self.failures.count) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"无法解析的 ExHentai 链接有 %ld 条重复", beforeFailuresCount - self.failures.count];
    }
    if (self.failures.count > 0) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"本次流程有%ld个页面无法解析，一共有 %ld 个", self.failures.count - [self.existCount[2] integerValue], self.failures.count];
    }
    [self.failures exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourceExHentaiFailureCommentPixivURLsFilePath]];
    
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"获取评论中Pixiv链接, 流程结束"];
}


@end
