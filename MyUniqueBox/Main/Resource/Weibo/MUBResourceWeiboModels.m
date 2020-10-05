//
//  MUBResourceWeiboModels.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/28.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBResourceWeiboModels.h"

@implementation MUBResourceWeiboUserModel

// 返回一个 Dict，将 Model 属性名对映射到 JSON 的 Key。Key 为 Property，Value 为 JSON 的 Key
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"_id"          : @"id",
        @"screenName"   : @"screen_name",
    };
}

@end

@implementation MUBResourceWeiboStatusModel

// 返回一个 Dict，将 Model 属性名对映射到 JSON 的 Key。Key 为 Property，Value 为 JSON 的 Key
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"createdAt"        : @"created_at",
        @"_id"              : @"id",
        @"picUrls"          : @"pic_urls",
        @"retweetedStatus"  : @"retweeted_status",
    };
}

- (void)setCreatedAt:(NSString *)createdAt {
    _createdAt = [createdAt copy];
    _createdAtDate = [NSDate dateWithString:createdAt formatString:MUBTimeFormatEMdHmsZy];
    _createdAtReadableStr = [_createdAtDate formattedDateWithFormat:MUBTimeFormatyMdHmsCompact];
    _createdAtSqliteStr = [_createdAtDate formattedDateWithFormat:MUBTimeFormatyMdHms];
}
- (void)setPicUrls:(NSArray *)picUrls {
    _picUrls = [picUrls copy];
    _imgUrls = [_picUrls bk_map:^id(NSDictionary *obj) {
        return [obj[@"thumbnail_pic"] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"large"];
    }];
    if (!_imgUrls.isNotEmpty) {
        _imgUrls = @[];
    }
    _imgUrlsStr = [_imgUrls componentsJoinedByString:@";"];
}
- (NSArray *)imgUrls {
    if (!_imgUrls) {
        _imgUrls = @[];
    }
    
    return _imgUrls;
}
- (NSString *)imgUrlsStr {
    if (!_imgUrlsStr) {
        _imgUrlsStr = @"";
    }
    
    return _imgUrlsStr;
}

@end

@implementation MUBResourceWeiboFavouriteModel

// 返回一个 Dict，将 Model 属性名对映射到 JSON 的 Key。Key 为 Property，Value 为 JSON 的 Key
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"favoritedTime": @"favorited_time",
    };
}

@end
