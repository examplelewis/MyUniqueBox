//
//  MUBSettingWeiboModels.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/14.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBSettingWeiboModels.h"

@implementation MUBSettingWeiboAuthModel

// 返回一个 Dict，将 Model 属性名对映射到 JSON 的 Key。Key 为 Property，Value 为 JSON 的 Key
+ (NSDictionary *)modelCustomPropertyMapper {
//    return @{
//        @"accessURL"            : @"access_url",
//        @"expiresAt"            : @"expires_at",
//        @"getAccessTokenUrl"    : @"get_access_token_url",
//    };
    return @{
        @"accessURL"            : @"weibo_access_url",
        @"expiresAt"            : @"weibo_expires_at",
        @"getAccessTokenUrl"    : @"weibo_get_access_token_url",
        @"code"            : @"weibo_code",
        @"token"            : @"weibo_token",
        @"url"    : @"weibo_url",
    };
}

@end

//------------------------------

@implementation MUBSettingWeiboBoundaryModel

// 返回一个 Dict，将 Model 属性名对映射到 JSON 的 Key。Key 为 Property，Value 为 JSON 的 Key
+ (NSDictionary *)modelCustomPropertyMapper {
//    return @{
//        @"_id" : @"id",
//    };
    return @{
        @"author" : @"weibo_boundary_author",
        @"_id" : @"weibo_boundary_id",
        @"text" : @"weibo_boundary_text",
    };
}

@end
