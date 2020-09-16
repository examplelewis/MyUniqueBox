//
//  MUBSettingDeviantartModels.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/14.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MUBSettingDeviantartAuthModel : MUBModel

@property (strong) NSString *accessToken;
@property (assign) NSTimeInterval expiresAt;
@property (assign) NSTimeInterval expiresIn;
@property (assign) NSTimeInterval refreshTime;
@property (strong) NSString *refreshToken;
@property (strong) NSString *scope;
@property (strong) NSString *status;
@property (strong) NSString *tokenType;

@end

//------------------------------

@interface MUBSettingDeviantartBoundaryModel : MUBModel

@property (assign) NSTimeInterval publishedTime;

@end

NS_ASSUME_NONNULL_END
