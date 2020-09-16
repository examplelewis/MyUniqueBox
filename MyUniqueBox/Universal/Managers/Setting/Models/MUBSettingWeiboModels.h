//
//  MUBSettingWeiboModels.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/14.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MUBSettingWeiboAuthModel : MUBModel

@property (strong) NSString *accessURL;
@property (strong) NSString *code;
@property (strong) NSString *expiresAt;
@property (strong) NSString *getAccessTokenUrl;
@property (strong) NSString *token;
@property (strong) NSString *url;

@end

//------------------------------

@interface MUBSettingWeiboBoundaryModel : MUBModel

@property (strong) NSString *author;
@property (strong) NSString *_id;
@property (strong) NSString *text;

@end

NS_ASSUME_NONNULL_END
