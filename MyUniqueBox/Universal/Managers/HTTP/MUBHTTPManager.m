//
//  MUBHTTPManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/29.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBHTTPManager.h"
#import <AFNetworking/AFNetworking.h>

#import "MUBHTTPHeader.h"

@implementation MUBHTTPManager

- (void)GET:(NSString *)url parameters:(id)parameters completionHandler:(nonnull void (^)(NSURLResponse *response, id _Nullable responseObject, NSError * _Nullable error))completionHandler {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET" URLString:url parameters:parameters error:nil];
    request.timeoutInterval = 15.0f;

    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            completionHandler(response, responseObject, error);
            return;
        }
        
        if (!((NSString *)responseObject).isNotEmpty) {
            completionHandler(response, responseObject, [NSError errorWithDomain:MUBErrorDomainHTTP code:MUBErrorCodeAPIReturnEmptyObject userInfo:@{NSLocalizedDescriptionKey: MUBErrorLocalizedDescriptionAPIReturnEmptyObject}]);
            return;
        }
        if (!((NSArray *)responseObject).isNotEmpty) {
            completionHandler(response, responseObject, [NSError errorWithDomain:MUBErrorDomainHTTP code:MUBErrorCodeAPIReturnEmptyObject userInfo:@{NSLocalizedDescriptionKey: MUBErrorLocalizedDescriptionAPIReturnEmptyObject}]);
            return;
        }
        if (!((NSDictionary *)responseObject).isNotEmpty) {
            completionHandler(response, responseObject, [NSError errorWithDomain:MUBErrorDomainHTTP code:MUBErrorCodeAPIReturnEmptyObject userInfo:@{NSLocalizedDescriptionKey: MUBErrorLocalizedDescriptionAPIReturnEmptyObject}]);
            return;
        }
        
        completionHandler(response, responseObject, nil);
    }];
    [dataTask resume];
}

- (void)POST:(NSString *)url parameters:(id)parameters completionHandler:(nonnull void (^)(NSURLResponse *response, id _Nullable responseObject, NSError * _Nullable error))completionHandler {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    manager.responseSerializer = responseSerializer;
    
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:@"POST" URLString:url parameters:parameters error:nil];
    request.timeoutInterval = 15.0f;

    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            completionHandler(response, responseObject, error);
            return;
        }
        
        if (!((NSString *)responseObject).isNotEmpty) {
            completionHandler(response, responseObject, [NSError errorWithDomain:MUBErrorDomainHTTP code:MUBErrorCodeAPIReturnEmptyObject userInfo:@{NSLocalizedDescriptionKey: MUBErrorLocalizedDescriptionAPIReturnEmptyObject}]);
            return;
        }
        if (!((NSArray *)responseObject).isNotEmpty) {
            completionHandler(response, responseObject, [NSError errorWithDomain:MUBErrorDomainHTTP code:MUBErrorCodeAPIReturnEmptyObject userInfo:@{NSLocalizedDescriptionKey: MUBErrorLocalizedDescriptionAPIReturnEmptyObject}]);
            return;
        }
        if (!((NSDictionary *)responseObject).isNotEmpty) {
            completionHandler(response, responseObject, [NSError errorWithDomain:MUBErrorDomainHTTP code:MUBErrorCodeAPIReturnEmptyObject userInfo:@{NSLocalizedDescriptionKey: MUBErrorLocalizedDescriptionAPIReturnEmptyObject}]);
            return;
        }
        
        completionHandler(response, responseObject, nil);
    }];
    [dataTask resume];
}

- (void)POSTWeibo:(NSString *)url parameters:(id)parameters completionHandler:(nonnull void (^)(NSURLResponse *response, id _Nullable responseObject, NSError * _Nullable error))completionHandler {
    NSMutableArray *paras = [NSMutableArray array];
    for (NSInteger i = 0; i < [parameters allKeys].count; i++) {
        NSString *key = [parameters allKeys][i];
        NSString *value = [parameters objectForKey:key];
        
        [paras addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
    }
    NSString *requestURL = [NSString stringWithFormat:@"%@?%@", url, [paras componentsJoinedByString:@"&"]];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:@"POST" URLString:requestURL parameters:nil error:nil];
    request.timeoutInterval = 15.0f;

    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            completionHandler(response, responseObject, error);
            return;
        }
        
        if (!((NSString *)responseObject).isNotEmpty) {
            completionHandler(response, responseObject, [NSError errorWithDomain:MUBErrorDomainHTTP code:MUBErrorCodeAPIReturnEmptyObject userInfo:@{NSLocalizedDescriptionKey: MUBErrorLocalizedDescriptionAPIReturnEmptyObject}]);
            return;
        }
        if (!((NSArray *)responseObject).isNotEmpty) {
            completionHandler(response, responseObject, [NSError errorWithDomain:MUBErrorDomainHTTP code:MUBErrorCodeAPIReturnEmptyObject userInfo:@{NSLocalizedDescriptionKey: MUBErrorLocalizedDescriptionAPIReturnEmptyObject}]);
            return;
        }
        if (!((NSDictionary *)responseObject).isNotEmpty) {
            completionHandler(response, responseObject, [NSError errorWithDomain:MUBErrorDomainHTTP code:MUBErrorCodeAPIReturnEmptyObject userInfo:@{NSLocalizedDescriptionKey: MUBErrorLocalizedDescriptionAPIReturnEmptyObject}]);
            return;
        }
        
        completionHandler(response, responseObject, nil);
    }];
    [dataTask resume];
}

@end
