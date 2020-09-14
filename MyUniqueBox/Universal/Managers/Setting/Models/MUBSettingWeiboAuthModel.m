//
//  MUBSettingWeiboAuthModel.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/14.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBSettingWeiboAuthModel.h"

@implementation MUBSettingWeiboAuthModel

// 返回一个 Dict，将 Model 属性名对映射到 JSON 的 Key。Key 为 Property，Value 为 JSON 的 Key
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"accessURL"            : @"access_url",
        @"expiresAt"            : @"expires_at",
        @"getAccessTokenUrl"    : @"get_access_token_url",
    };
}

@end
