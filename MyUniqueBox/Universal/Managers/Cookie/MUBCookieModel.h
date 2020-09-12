//
//  MUBCookieModel.h
//  MyUniqueBox
//
//  Created by 龚宇 on 2020/9/12.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUBModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MUBCookieModel : MUBModel

@property (strong) NSString *domain;
@property (assign) NSTimeInterval expirationDate;
@property (assign) NSInteger hostOnly;
@property (assign) NSInteger httpOnly;
@property (assign) NSInteger _id;
@property (strong) NSString *name;
@property (strong) NSString *path;
@property (strong) NSString *sameSite;
@property (assign) NSInteger secure;
@property (assign) NSInteger session;
@property (assign) NSInteger storeId;
@property (strong) NSString *value;

@end

NS_ASSUME_NONNULL_END
