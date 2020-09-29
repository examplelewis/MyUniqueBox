//
//  MUBDownloadSettingManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/23.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUBDownloadSettingModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MUBDownloadSettingManager : NSObject

@property (nonatomic, strong) MUBDownloadSettingModel *defaultPrefModel;

+ (instancetype)defaultManager;

- (void)updatePreferences;
- (void)updateDefaultPrefrenceWithModel:(MUBDownloadSettingModel *)model;
- (void)updatePreferenceWithName:(NSString *)name model:(MUBDownloadSettingModel *)model;

#pragma mark - Pref Model
// menuItemTag 和 prefTag 相同
- (MUBDownloadSettingModel *)prefModelFromMenuItemTag:(NSInteger)tag;

#pragma mark - Menu Item
- (void)updateMenuItems;

@end

NS_ASSUME_NONNULL_END
