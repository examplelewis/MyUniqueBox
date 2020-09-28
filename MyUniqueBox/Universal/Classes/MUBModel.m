//
//  MUBModel.m
//  MyUniqueBox
//
//  Created by 龚宇 on 2020/9/12.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBModel.h"

@implementation MUBModel

+ (NSArray * _Nullable)modelsFromJSONs:(NSArray *)jsons {
    if (!jsons || jsons.isNotArray) {
        return nil;
    }
    
    NSMutableArray *models = [NSMutableArray array];
    for (NSDictionary *json in jsons) {
        id model = [[self class] yy_modelWithJSON:json];
        if (model) {
            [models addObject:model];
        }
    }
    
    return models;
}

@end
