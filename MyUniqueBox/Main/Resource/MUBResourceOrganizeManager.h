//
//  MUBResourceOrganizeManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/10/01.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MUBResourceOrganizeType) {
    MUBResourceOrganizeTypeJDLingyu,
    MUBResourceOrganizeTypeWeibo,
};

@class MUBResourceOrganizeManager;

@protocol MUBResourceOrganizeManagerDelegate <NSObject>

- (void)managerDidFinishOrganizing:(MUBResourceOrganizeManager*)manager;

@end

@interface MUBResourceOrganizeManager : NSObject

@property (weak) id <MUBResourceOrganizeManagerDelegate> delegate;

+ (instancetype)managerWithType:(MUBResourceOrganizeType)type plistPath:(NSString * _Nullable)plistPath;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (void)start;

@end

NS_ASSUME_NONNULL_END
