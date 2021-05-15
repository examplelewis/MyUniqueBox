//
//  MUBFileOperationModel.h
//  MyUniqueBox
//
//  Created by 龚宇 on 21/05/15.
//  Copyright © 2021 龚宇. All rights reserved.
//

#import "MUBModel.h"

typedef NS_ENUM(NSInteger, MUBFileOperationLevel) {
    MUBFileOperationLevelSeparator = -1,
    MUBFileOperationLevelDisabled = 0,
    MUBFileOperationLevelEnabledButNotTest = 1,
    MUBFileOperationLevelEnabled = 2,
};

NS_ASSUME_NONNULL_BEGIN

@interface MUBFileOperationModel : MUBModel

@property (nonatomic, assign) NSInteger oID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *oDesc;
@property (nonatomic, copy) NSString *keywordsStr;
@property (nonatomic, copy) NSArray *keywords;
@property (nonatomic, assign) MUBFileOperationLevel level;
@property (nonatomic, copy) NSString *groupTitle;

+ (instancetype)separatorModelForID:(NSInteger)oID;

@end

NS_ASSUME_NONNULL_END
