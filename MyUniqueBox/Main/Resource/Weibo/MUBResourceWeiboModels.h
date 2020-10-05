//
//  MUBResourceWeiboModels.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/28.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MUBResourceWeiboUserModel : MUBModel

@property (assign) NSInteger _id;
@property (copy) NSString *idstr;
@property (copy) NSString *screenName;

@end

@interface MUBResourceWeiboStatusModel : MUBModel

@property (nonatomic, copy) NSString *createdAt;
@property (assign) BOOL deleted;
@property (assign) BOOL favorited;
@property (assign) NSInteger _id;
@property (copy) NSString *idstr;
@property (nonatomic, copy) NSArray *picUrls;
@property (strong) MUBResourceWeiboStatusModel *retweetedStatus;
@property (copy) NSString *text;
@property (strong) MUBResourceWeiboUserModel *user;

@property (strong) NSDate *createdAtDate;
@property (copy) NSString *createdAtReadableStr;
@property (copy) NSString *createdAtSqliteStr;

@property (nonatomic, copy) NSArray *imgUrls;
@property (nonatomic, copy) NSString *imgUrlsStr;

@end

@interface MUBResourceWeiboFavouriteModel : MUBModel

@property (copy) NSString *favoritedTime;
@property (strong) MUBResourceWeiboStatusModel *status;
@property (copy) NSArray *tags;

@end

NS_ASSUME_NONNULL_END
