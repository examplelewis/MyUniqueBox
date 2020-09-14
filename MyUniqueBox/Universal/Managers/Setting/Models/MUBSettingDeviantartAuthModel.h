//
//  MUBSettingDeviantartAuthModel.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/14.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MUBSettingDeviantartAuthModel : MUBModel

@property (strong) NSString *accessToken;
@property (strong) NSString *expiresAt;
@property (strong) NSString *expiresIn;
@property (strong) NSString *refreshTime;
@property (strong) NSString *refreshToken;
@property (strong) NSString *scope;
@property (strong) NSString *status;
@property (strong) NSString *tokenType;

@end

NS_ASSUME_NONNULL_END
