//
//  MUBResourceExHentaiModels.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/10/02.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBResourceExHentaiModels.h"

@implementation MUBResourceExHentaiPageModel

// 返回一个 Dict，将 Model 属性名对映射到 JSON 的 Key。Key 为 Property，Value 为 JSON 的 Key
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"archiverKey"  : @"archiver_key",
        @"titleJpn"     : @"title_jpn",
    };
}

@end
