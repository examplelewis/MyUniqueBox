//
//  MUBHTTPExHentaiManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/10/02.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBHTTPExHentaiManager.h"
#import <AFNetworking/AFNetworking.h>
#import "MUBHTTPHeader.h"

@implementation MUBHTTPExHentaiManager

#pragma mark - Lifecycle
+ (instancetype)defaultManager {
    static MUBHTTPExHentaiManager *defaultManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [[self alloc] init];
    });
    
    return defaultManager;
}

- (void)getPostDetailWithPageURL:(NSString *)pageURL completionHandler:(void (^)(NSURLResponse * _Nonnull, NSArray<MUBResourceExHentaiPageModel *> * _Nullable, NSError * _Nullable))completionHandler {
    NSString *url = @"https://api.e-hentai.org/api.php";
    NSArray *urlComps = [NSURL URLWithString:pageURL].pathComponents;
    NSDictionary *parameters = @{
        @"method": @"gdata",
        @"gidlist": @[@[urlComps[2], urlComps[3]]],
        @"namespace": @(1),
    };
    
    [self POST:url parameters:parameters completionHandler:^(NSURLResponse * _Nonnull response, NSDictionary * _Nullable object, NSError * _Nullable error) {
        if (error) {
            completionHandler(response, nil, error);
            return;
        }
        
        NSLog(@"getPostDetailWithPageURL: %@", object[@"gmetadata"]);
        NSArray<MUBResourceExHentaiPageModel *> *models = [MUBResourceExHentaiPageModel modelsFromJSONs:object[@"gmetadata"]];
        if (!models) {
            completionHandler(response, nil, [NSError errorWithDomain:MUBErrorDomainHTTPExHentaiAPI code:MUBErrorCodeAPIReturnUselessObject userInfo:@{NSLocalizedDescriptionKey: MUBErrorLocalizedDescriptionAPIReturnUselessObject}]);
            return;
        }
        
        completionHandler(response, models, nil);
    }];
}

@end
