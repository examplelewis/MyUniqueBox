//
//  MUBMenuItemResourceWeiboManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/28.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBMenuItemResourceWeiboManager.h"
#import "MUBMenuItemResourceHeader.h"

#import "MUBResourceWeiboFavouriteManager.h"
#import "MUBResourceWeiboFaviouriteDuplicateManager.h"
#import "MUBResourceWeiboBoundaryManager.h"
#import "MUBResourceWeiboFavouriteLess9ImagesManager.h"
#import "MUBResourceOrganizeManager.h"

@implementation MUBMenuItemResourceWeiboManager

+ (void)customMenuItemDidPress:(NSMenuItem *)sender {
    NSInteger type = (sender.tag - kMUBMenuItemResourceTagOffset) / 10000;
    NSInteger section = (sender.tag - kMUBMenuItemResourceTagOffset - type * 10000) / 100;
    NSInteger action = (sender.tag - kMUBMenuItemResourceTagOffset) % 100;
    
    switch (section) {
        case 0: {
            switch (action) {
                case 1: {
                    [[MUBLogManager defaultManager] reset];
                    [[MUBResourceWeiboFavouriteManager new] start];
                }
                    break;
                case 2: {
                    [[MUBLogManager defaultManager] reset];
                    
                    NSInteger maxFetchCount = [[MUBUIManager defaultManager].viewController.inputTextView.string integerValue];
                    if (maxFetchCount <= 0) {
                        [[MUBLogManager defaultManager] addWarningLogWithFormat:@"输入的数量必须大于0"];
                        return;
                    }
                    
                    MUBResourceWeiboFavouriteManager *manager = [MUBResourceWeiboFavouriteManager new];
                    manager.maxFetchCount = maxFetchCount;
                    [manager start];
                }
                    break;
                case 98: {
                    [MUBResourceWeiboFavouriteManager outputFolderNameFromWeiboStatusText:nil];
                }
                    break;
                case 99: {
                    [[MUBResourceOrganizeManager managerWithType:MUBResourceOrganizeTypeWeibo plistPath:nil] start];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 1: {
            switch (action) {
                case 1: {
                    [[MUBLogManager defaultManager] reset];
                    [[MUBResourceWeiboFaviouriteDuplicateManager new] start];
                }
                    break;
                case 2: {
                    [[MUBLogManager defaultManager] reset];
                    [[MUBResourceWeiboFavouriteLess9ImagesManager new] start];
                }
                    break;
                case 99: {
                    [[MUBLogManager defaultManager] reset];
                    [MUBResourceWeiboFaviouriteDuplicateManager unfavouriteDuplicateWeibos];
                }
                    break;
                default:
                    break;
            }
        }
            break;
//        case 2: {
//            switch (action) {
//                case 1: {
//
//                }
//                    break;
//                case 2: {
//
//                }
//                    break;
//                default:
//                    break;
//            }
//        }
//            break;
        case 3: {
            switch (action) {
                case 1: {
                    
                }
                    break;
                case 2: {
                    
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 4: {
            switch (action) {
//                case 1: {
//
//                }
//                    break;
                case 2: {
                    [[MUBLogManager defaultManager] reset];
                    [MUBResourceWeiboBoundaryManager markNewestFavorAsBoundary];
                }
                    break;
                default:
                    break;
            }
        }
            break;
//        case 5: {
//            switch (action) {
//                case 1: {
//
//                }
//                    break;
//                default:
//                    break;
//            }
//        }
//            break;
        default:
            break;
    }
}

@end
