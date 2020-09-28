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

- (void)POST:(NSString *)url parameters:(id)parameters completionHandler:(nonnull void (^)(NSURLResponse *response, id _Nullable responseObject, NSError * _Nullable error))completionHandler {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET" URLString:url parameters:parameters error:nil];
    request.timeoutInterval = 15.0f;

    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            completionHandler(response, nil, error);
            return;
        }
        
        if ([responseObject isKindOfClass:[NSString class]] && ((NSString *)responseObject).isEmpty) {
            completionHandler(response, nil, [NSError errorWithDomain:MUBErrorDomainHTTP code:MUBErrorCodeAPIReturnEmptyObject userInfo:@{NSLocalizedDescriptionKey: MUBErrorLocalizedDescriptionAPIReturnEmptyObject}]);
            return;
        }
        if ([responseObject isKindOfClass:[NSArray class]] && ((NSArray *)responseObject).isEmpty) {
            completionHandler(response, nil, [NSError errorWithDomain:MUBErrorDomainHTTP code:MUBErrorCodeAPIReturnEmptyObject userInfo:@{NSLocalizedDescriptionKey: MUBErrorLocalizedDescriptionAPIReturnEmptyObject}]);
            return;
        }
        if ([responseObject isKindOfClass:[NSDictionary class]] && ((NSDictionary *)responseObject).isEmpty) {
            completionHandler(response, nil, [NSError errorWithDomain:MUBErrorDomainHTTP code:MUBErrorCodeAPIReturnEmptyObject userInfo:@{NSLocalizedDescriptionKey: MUBErrorLocalizedDescriptionAPIReturnEmptyObject}]);
            return;
        }
        
        completionHandler(response, responseObject, nil);
    }];
    [dataTask resume];
}

@end
