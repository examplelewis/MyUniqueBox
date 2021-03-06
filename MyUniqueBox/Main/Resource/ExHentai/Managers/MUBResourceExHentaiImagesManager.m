//
//  MUBResourceExHentaiImagesManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/10/02.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBResourceExHentaiImagesManager.h"
#import <hpple/TFHpple.h>
#import "MUBResourceExHentaiHeader.h"

@interface MUBResourceExHentaiImagesManager ()

@property (copy) NSArray *URLs;

@property (assign) NSInteger download;
@property (strong) NSMutableArray<MUBResourceExHentaiImageModel *> *imageModels;
@property (strong) NSMutableArray *failures;

@end

@implementation MUBResourceExHentaiImagesManager

#pragma mark - Lifecycle
+ (instancetype)managerWithURLs:(NSArray *)URLs {
    MUBResourceExHentaiImagesManager *manager = [MUBResourceExHentaiImagesManager new];
    manager.URLs = URLs;
    return manager;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.download = 0;
        self.imageModels = [NSMutableArray array];
        self.failures = [NSMutableArray array];
    }
    
    return self;
}

- (void)start {
    [[MUBUIManager defaultManager] resetProgressIndicatorMaxValue: (double)self.URLs.count];
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"开始获取网页中的图片链接"];
    
    for (NSInteger i = 0; i < self.URLs.count; i++) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.URLs[i]]
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:60.0f];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                [[MUBLogManager defaultManager] addErrorLogWithFormat:@"获取网页信息失败，原因：%@", error.localizedDescription];
                
                [self.failures addObject:self.URLs[i]];
                [self.failures exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourceExHentaiFailureImagesFilePath]];
            } else {
                TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
                // 查找是否包含 Download Original 的链接
                BOOL foundOrigin = NO;
                NSArray *aArray = [xpathParser searchWithXPathQuery:@"//a"];
                for (TFHppleElement *element in aArray) {
                    if ([element.raw containsString:@"Download original"]) {
                        foundOrigin = YES;
                        
                        MUBResourceExHentaiImageModel *imageModel = [MUBResourceExHentaiImageModel new];
                        imageModel.downloadURL = element.attributes[@"href"];
                        imageModel.pageURL = self.URLs[i];
                        
                        [self.imageModels addObject:imageModel];
                    }
                }
                
                // 如果没有找到 Original 的图片地址，再解析网页中的图片地址
                if (!foundOrigin) {
                    NSArray *imgArray = [xpathParser searchWithXPathQuery:@"//img"];
                    for (TFHppleElement *element in imgArray) {
                        NSString *href = element.attributes[@"src"];
                        if ([element.attributes[@"id"] isEqualToString:@"img"]) {
                            MUBResourceExHentaiImageModel *imageModel = [MUBResourceExHentaiImageModel new];
                            imageModel.downloadURL = href;
                            imageModel.pageURL = self.URLs[i];
                            
                            [self.imageModels addObject:imageModel];
                        }
                        
//                        if ([href hasPrefix:@"http://1"] || [href hasPrefix:@"http://2"] || [href hasPrefix:@"http://3"] || [href hasPrefix:@"http://4"] || [href hasPrefix:@"http://5"] || [href hasPrefix:@"http://6"] || [href hasPrefix:@"http://7"] || [href hasPrefix:@"http://8"] || [href hasPrefix:@"http://9"]) {
//                            [self.imageURLs addObject:href];
//                        }
                    }
                }
                
                [[self.imageModels valueForKey:@"downloadURL"] exportToPath:[[MUBSettingManager defaultManager] pathOfContentInDownloadFolder:MUBResourceExHentaiSuccessImagesFilePath]];
            }
            
            [self didFinishDownloadingOnePicture];
        }];
        [task resume];
    }
}

// 完成下载图片地址的方法
- (void)didFinishDownloadingOnePicture {
    self.download += 1;
    [[MUBUIManager defaultManager] updateProgressIndicatorDoubleValue:(double)self.download];
    if (self.download != self.URLs.count) {
        return;
    }
    
    if (self.failures.count > 0) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"有 %ld 个网页无法获取图片链接，已导出到下载文件夹的 MUBResourceExHentaiFailureImages.txt 文件中", self.failures.count];
        self.model.remarks = [self.model.remarks arrayByAddingObject:[NSString stringWithFormat:@"有 %ld 个网页无法获取图片链接", self.failures.count]];
    }
    
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"成功获取到%ld条数据", self.imageModels.count];
    
    if ([self.delegate respondsToSelector:@selector(manager:model:didGetAllImageModels:error:)]) {
        [self.delegate manager:self model:self.model didGetAllImageModels:self.imageModels.copy error:nil];
    }
}


@end
