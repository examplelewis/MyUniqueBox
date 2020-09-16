//
//  MUBSettingDeviantartModels.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/14.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBSettingDeviantartModels.h"

@implementation MUBSettingDeviantartAuthModel

// 返回一个 Dict，将 Model 属性名对映射到 JSON 的 Key。Key 为 Property，Value 为 JSON 的 Key
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"accessToken"  : @"access_token",
        @"expiresAt"    : @"expires_at",
        @"expiresIn"    : @"expires_in",
        @"refreshTime"  : @"refresh_time",
        @"refreshToken" : @"refresh_token",
        @"tokenType"    : @"token_type",
    };
}

@end

//------------------------------

@implementation MUBSettingDeviantartBoundaryModel

// 返回一个 Dict，将 Model 属性名对映射到 JSON 的 Key。Key 为 Property，Value 为 JSON 的 Key
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"publishedTime" : @"published_time",
    };
}

@end
