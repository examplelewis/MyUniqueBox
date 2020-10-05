//
//  MUBCookieManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 2020/9/12.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBCookieManager.h"
#import "MUBCookieModel.h"

@interface MUBCookieManager ()

@property (nonatomic, assign) MUBCookieType type;

@property (copy) NSString *fileName;
@property (copy) NSString *domain;
@property (copy) NSArray<MUBCookieModel *> *models;

@end

@implementation MUBCookieManager

#pragma mark - Lifecycle
+ (instancetype)managerWithType:(MUBCookieType)type {
    MUBCookieManager *manager = [MUBCookieManager new];
    manager.type = type;
    if (manager.fileName.isNotEmpty) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
        [manager _readCookie];
    }
    
    return manager;
}

- (void)_readCookie {
    NSString *filePath = [[MUBSettingManager defaultManager] pathOfContentInMainFolder:[NSString stringWithFormat:@"Cookies/%@", self.fileName]];
    NSString *cookieStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    self.models = [NSArray yy_modelArrayWithClass:[MUBCookieModel class] json:cookieStr];
}

- (void)writeCookies {
    // Cookie即将过期，需要使用Chrome再次请求Cookie
    NSDate *expireDate = [NSDate dateWithTimeIntervalSince1970:[[self.models valueForKeyPath:@"@max.expirationDate"] doubleValue]];
    if ([expireDate isEarlierThan:[NSDate date]]) {
        [MUBAlertManager showWarningAlertOnKeyWindowWithMessage:@"有部分Cookie即将过期" info:@"需要使用Chrome再次请求Cookie" runModal:NO handler:nil];
    }
    
    for (NSInteger i = 0; i < self.models.count; i++) {
        MUBCookieModel *model = self.models[i];
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:@{NSHTTPCookieName:model.name, NSHTTPCookieValue:model.value, NSHTTPCookieDomain:model.domain, NSHTTPCookieOriginURL:model.domain, NSHTTPCookiePath:model.path, NSHTTPCookieExpires:[NSDate dateWithTimeIntervalSince1970:model.expirationDate]}];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }
}

- (void)deleteCookieByName:(NSString *)name {
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:self.domain]];
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.name isEqualToString:name]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
}

- (void)outputCookies {
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:self.domain]];
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"outputCookies start: %@", self.domain];
    for (NSHTTPCookie *cookie in cookies) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"%@: %@", cookie.name, cookie.value];
    }
    [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"outputCookies end"];
}

#pragma mark - Setter
- (void)setType:(MUBCookieType)type {
    _type = type;
    
    if (type == MUBCookieTypeBCY) {
        _fileName = @"BCYCookie.txt";
        _domain = @"http://bcy.net/";
    } else if (type == MUBCookieTypeExHentai) {
        _fileName = @"ExHentaiCookie.txt";
        _domain = @"https://exhentai.org/";
    } else if (type == MUBCookieTypeWorldCosplay) {
        _fileName = @"WorldCosplayCookie.txt";
        _domain = @"https://worldcosplay.net/";
    } else {
        _fileName = @"";
        _domain = @"";
    }
}

@end
