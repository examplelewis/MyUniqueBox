//
//  MUBHTTPWeiboManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/28.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBHTTPWeiboManager.h"
#import <AFNetworking/AFNetworking.h>
#import "XMLReader.h"

#import "MUBHTTPHeader.h"
#import "MUBResourceWeiboModels.h"

@implementation MUBHTTPWeiboManager

#pragma mark - Lifecycle
+ (instancetype)defaultManager {
    static MUBHTTPWeiboManager *defaultManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [[self alloc] init];
    });
    
    return defaultManager;
}

#pragma mark - Weibo
- (void)getWeiboTokenWithSuccess:(void(^)(NSDictionary *dic))success failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed {
    NSString *url = @"https://api.weibo.com/oauth2/access_token";
    NSDictionary *parameters = @{
        @"client_id": @"587160380",
        @"client_secret": @"d44d86c3ba2fbabf9a197f4514a67d21",
        @"redirect_uri": @"myresourcebox://success.html",
        @"grant_type": @"authorization_code",
        @"code": [MUBSettingManager defaultManager].weiboAuthModel.code,
    };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:url parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *error;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
        if (error) { // 如果解析出现错误
            if (failed) {
                failed(@"数据解析发生错误", [error localizedDescription]);
            }
        } else {
            if (success) {
                success(dict);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed) {
            failed(@"服务器通讯发生错误", [error localizedDescription]);
        }
    }];
}
- (void)getWeiboTokenInfoWithSuccess:(void(^)(NSDictionary *dic))success failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed {
    NSString *url = @"https://api.weibo.com/oauth2/get_token_info";
    NSDictionary *parameters = @{
        @"access_token": [MUBSettingManager defaultManager].weiboAuthModel.token,
    };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:url parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *error;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
        if (error) { // 如果解析出现错误
            if (failed) {
                failed(@"数据解析发生错误", [error localizedDescription]);
            }
        } else {
            if (success) {
                success(dict);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed) {
            failed(@"服务器通讯发生错误", [error localizedDescription]);
        }
    }];
}
- (void)getWeiboLimitInfoWithSuccess:(void(^)(NSDictionary *dic))success failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed {
    NSString *url = @"https://api.weibo.com/2/account/rate_limit_status.json";
    NSDictionary *parameters = @{
        @"access_token": [MUBSettingManager defaultManager].weiboAuthModel.token,
    };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:url parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *error;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
        if (error) { // 如果解析出现错误
            if (failed) {
                failed(@"数据解析发生错误", [error localizedDescription]);
            }
        } else {
            if (success) {
                success(dict);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed) {
            failed(@"服务器通讯发生错误", [error localizedDescription]);
        }
    }];
}
- (void)getWeiboFavoritesWithPage:(NSInteger)page completionHandler:(void (^)(NSURLResponse * _Nonnull, NSArray<MUBResourceWeiboFavouriteModel *> * _Nullable, NSError * _Nullable))completionHandler {
    NSString *url = @"https://api.weibo.com/2/favorites.json";
    NSDictionary *parameters = @{
        @"access_token": [MUBSettingManager defaultManager].weiboAuthModel.token,
        @"count": @(50),
        @"page": @(page),
    };
    
    [self POST:url parameters:parameters completionHandler:^(NSURLResponse * _Nonnull response, NSDictionary * _Nullable object, NSError * _Nullable error) {
        if (error) {
            completionHandler(response, nil, error);
            return;
        }
        
        NSArray<MUBResourceWeiboFavouriteModel *> *models = [MUBResourceWeiboFavouriteModel modelsFromJSONs:object[@"favorites"]];
        if (!models) {
            completionHandler(response, nil, [NSError errorWithDomain:MUBErrorDomainHTTPWeiboAPI code:MUBErrorCodeAPIReturnUselessObject userInfo:@{NSLocalizedDescriptionKey: MUBErrorLocalizedDescriptionAPIReturnUselessObject}]);
            return;
        }
        
        completionHandler(response, models, nil);
    }];
}
- (void)deleteWeiboFavoriteWithStatusId:(NSString *)statusId success:(void(^)(NSDictionary *dic))success failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed {
    NSString *url = @"https://api.weibo.com/2/favorites/destroy.json";
    NSDictionary *parameters = @{
        @"access_token": [MUBSettingManager defaultManager].weiboAuthModel.token,
        @"id": @(statusId.integerValue),
    };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:url parameters:parameters headers:@{@"Content-Type": @"application/x-www-form-urlencoded"} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *error;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
        if (error) { // 如果解析出现错误
            if (failed) {
                failed(@"数据解析发生错误", [error localizedDescription]);
            }
        } else {
            if (success) {
                success(dict);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed) {
            failed(@"服务器通讯发生错误", [error localizedDescription]);
        }
    }];
}

@end
