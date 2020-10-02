//
//  MUBHTTPManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/29.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MUBHTTPManager : MUBModel

- (void)GET:(NSString *)url parameters:(id)parameters completionHandler:(nonnull void (^)(NSURLResponse *response, id _Nullable responseObject, NSError * _Nullable error))completionHandler;

- (void)POST:(NSString *)url parameters:(id)parameters completionHandler:(nonnull void (^)(NSURLResponse *response, id _Nullable responseObject, NSError * _Nullable error))completionHandler;

- (void)POSTWeibo:(NSString *)url parameters:(id)parameters completionHandler:(nonnull void (^)(NSURLResponse *response, id _Nullable responseObject, NSError * _Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
