//
//  MUBHTTPHeader.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/29.
//  Copyright © 2020 龚宇. All rights reserved.
//

#ifndef MUBHTTPHeader_h
#define MUBHTTPHeader_h

#pragma mark - Domain
static NSString * const MUBErrorDomainHTTP = @"com.gongyu.MyUniqueBox.HTTP";
static NSString * const MUBErrorDomainHTTPWeiboAPI = @"com.gongyu.MyUniqueBox.HTTP.weiboApi";
static NSString * const MUBErrorDomainHTTPExHentaiAPI = @"com.gongyu.MyUniqueBox.HTTP.exHentaiApi";


#pragma mark - Code
static NSInteger const MUBErrorCodeAPIReturnEmptyObject = -10001;
static NSInteger const MUBErrorCodeAPIReturnUselessObject = -10002;

#pragma mark - UserInfo
static NSString * const MUBErrorLocalizedDescriptionAPIReturnEmptyObject = @"接口返回空数据";
static NSString * const MUBErrorLocalizedDescriptionAPIReturnUselessObject = @"接口未返回可用数据";

#pragma mark - Weibo



#endif /* MUBHTTPHeader_h */
