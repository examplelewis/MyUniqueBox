//
//  MUBMenuItemResourcePixivManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/28.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBMenuItemResourcePixivManager.h"
#import "MUBMenuItemResourceHeader.h"
#import "MUBResourcePixivUniversalManager.h"

@implementation MUBMenuItemResourcePixivManager

+ (void)customMenuItemDidPress:(NSMenuItem *)sender {
    NSInteger type = (sender.tag - kMUBMenuItemResourceTagOffset) / 10000;
    NSInteger section = (sender.tag - kMUBMenuItemResourceTagOffset - type * 10000) / 100;
    NSInteger action = (sender.tag - kMUBMenuItemResourceTagOffset) % 100;
    
    switch (section) {
        case 0: {
            switch (action) {
//                case 1: {
//                    
//                }
//                    break;
//                case 2: {
//                    
//                }
//                    break;
//                case 3: {
//                    
//                }
//                    break;
//                case 4: {
//                    
//                }
//                    break;
                case 5: {
                    [MUBResourcePixivUniversalManager getInputsWithType:MUBResourcePixivUniversalTypeUpdateBlock1];
                }
                    break;
                case 6: {
                    [MUBResourcePixivUniversalManager getInputsWithType:MUBResourcePixivUniversalTypeUpdateBlock2];
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
                    [MUBResourcePixivUniversalManager getInputsWithType:MUBResourcePixivUniversalTypeFollowStatus];
                }
                    break;
                case 2: {
                    [MUBResourcePixivUniversalManager getInputsWithType:MUBResourcePixivUniversalTypeBlockStatus];
                }
                    break;
                case 3: {
                    [MUBResourcePixivUniversalManager getInputsWithType:MUBResourcePixivUniversalTypeFetchStatus];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 2: {
            switch (action) {
                case 1: {
                    
                }
                    break;
                case 2: {
                    
                }
                    break;
                case 3: {
                    [MUBResourcePixivUniversalManager getInputsWithType:MUBResourcePixivUniversalTypeExportFollowAndBlockUsers];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 3: {
            switch (action) {
                case 1: {
                    [MUBResourcePixivUniversalManager showOpenPanelWithType:MUBResourcePixivUniversalTypeGenerateIllustURLsFromImageFiles];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 4: {
            switch (action) {
                case 1: {
                    [MUBResourcePixivUniversalManager getInputsWithType:MUBResourcePixivUniversalTypeRemoveUsersDownloadRecords];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 5: {
            switch (action) {
                case 1: {
                    [MUBResourcePixivUniversalManager showOpenPanelWithType:MUBResourcePixivUniversalTypeOrganizeSameIllustIDImageFiles];
                }
                    break;
                default:
                    break;
            }
        }
            break;
//        case 6: {
//            switch (action) {
//                case 1: {
//
//                }
//                    break;
//                case 2: {
//
//                }
//                    break;
//                case 3: {
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
