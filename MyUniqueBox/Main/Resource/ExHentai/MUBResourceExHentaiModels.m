//
//  MUBResourceExHentaiModels.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/10/02.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBResourceExHentaiModels.h"

@implementation MUBResourceExHentaiPageModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.remarks = @[];
    }
    
    return self;
}

// 返回一个 Dict，将 Model 属性名对映射到 JSON 的 Key。Key 为 Property，Value 为 JSON 的 Key
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"archiverKey"  : @"archiver_key",
        @"titleJpn"     : @"title_jpn",
    };
}

// 返回容器类中的所需要存放的数据类型 (以 Class 或 Class Name 的形式)。
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"torrents": [MUBResourceExHentaiTorrentModel class],
    };
}

- (NSString *)remark {
    if (!_remark) {
        if (!self.remarks.isNotEmpty) {
            _remark = @"无";
        } else {
            _remark = [self.remarks componentsJoinedByString:@", "];
        }
    }
    
    return _remark;
}

@end

@implementation MUBResourceExHentaiTorrentModel

// 返回一个 Dict，将 Model 属性名对映射到 JSON 的 Key。Key 为 Property，Value 为 JSON 的 Key
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"tHash": @"hash",
    };
}

@end

@implementation MUBResourceExHentaiImageModel

- (void)setPageURL:(NSString *)pageURL {
    _pageURL = [pageURL copy];
    _pageToken = [pageURL componentsSeparatedByString:@"/"][4];
}

@end
