//
//  MUBFileOperationModel.m
//  MyUniqueBox
//
//  Created by 龚宇 on 21/05/15.
//  Copyright © 2021 龚宇. All rights reserved.
//

#import "MUBFileOperationModel.h"

@implementation MUBFileOperationModel

+ (instancetype)separatorModelForID:(NSInteger)oID {
    MUBFileOperationModel *model = [MUBFileOperationModel new];
    model.oID = oID;
    model.title = @"-------------------------------------------------";
    model.oDesc = @"";
    model.keywordsStr = @"";
    model.level = MUBFileOperationLevelSeparator;
    model.groupTitle = @"";
    
    return model;
}

#pragma mark - Setter
- (void)setKeywordsStr:(NSString *)keywordsStr {
    _keywordsStr = [keywordsStr copy];
    
    _keywords = [keywordsStr componentsSeparatedByString:@"、"];
}

@end
