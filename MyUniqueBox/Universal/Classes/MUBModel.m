//
//  MUBModel.m
//  MyUniqueBox
//
//  Created by 龚宇 on 2020/9/12.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBModel.h"

@implementation MUBModel

// 返回一个 Dict，将 Model 属性名对映射到 JSON 的 Key。
// Key 为 Model 里的值，Value 为 JSON 里的值。
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"_id": @"id"};
}

@end
