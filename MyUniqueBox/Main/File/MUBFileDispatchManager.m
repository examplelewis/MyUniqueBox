//
//  MUBFileDispatchManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 21/05/15.
//  Copyright © 2021 龚宇. All rights reserved.
//

#import "MUBFileDispatchManager.h"
#import "MUBFileUniversalManager.h"
#import "MUBFileSearchCharactersManager.h"
#import "MUBFileExtractTypeFileManager.h"

@implementation MUBFileDispatchManager

#pragma mark - Dispatch
+ (void)operationDispatchByOperationID:(NSInteger)oID {
    NSInteger type = oID / 100;
    NSInteger action = oID % 100;
    
    switch (type) {
        case 0: {
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
        case 1: {
            switch (action) {
                case 1: {
                    [[MUBLogManager defaultManager] reset];
                    [MUBFileUniversalManager showOpenPanelWithType:MUBFileUniversalTypeCopyFolderHierarchy];
                }
                    break;
                case 2: {
                    [[MUBLogManager defaultManager] reset];
                    [MUBFileUniversalManager operationWithType:MUBFileUniversalTypeCombineMultipleFolders];
                }
                    break;
                case 3: {
                    [[MUBLogManager defaultManager] reset];
                    [MUBFileUniversalManager showOpenPanelWithType:MUBFileUniversalTypeExtractSingleFolder];
                }
                    break;
                case 4: {
                    [[MUBLogManager defaultManager] reset];
                    [MUBFileUniversalManager showOpenPanelWithType:MUBFileUniversalTypeExtractSingleFile];
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
                    [[MUBLogManager defaultManager] reset];
                    [MUBFileUniversalManager showOpenPanelWithType:MUBFileUniversalTypeRenameAsSuperFodlerNameOnSingleFolder];
                }
                    break;
                case 2: {
                    [[MUBLogManager defaultManager] reset];
                    [MUBFileUniversalManager showOpenPanelWithType:MUBFileUniversalTypeRenameAsSuperFodlerNameOnSingleFile];
                }
                    break;
                case 3: {
                    [[MUBLogManager defaultManager] reset];
                    [MUBFileUniversalManager showOpenPanelWithType:MUBFileUniversalTypeRenameAsSuperFodlerNameOnSingleContent];
                }
                    break;
                case 4: {
                    
                }
                    break;
                case 5: {
                    [[MUBLogManager defaultManager] reset];
                    [MUBFileUniversalManager showOpenPanelWithType:MUBFileUniversalTypeRenameAddSuperFolderNameOnAllFolders];
                }
                    break;
                case 6: {
                    [[MUBLogManager defaultManager] reset];
                    [MUBFileUniversalManager showOpenPanelWithType:MUBFileUniversalTypeRenameAddSuperFolderNameOnAllContents];
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
                    [[MUBLogManager defaultManager] reset];
                    [MUBFileUniversalManager showOpenPanelWithType:MUBFileUniversalTypeTrashNoItemsFolder];
                }
                    break;
                case 2: {
                    [[MUBLogManager defaultManager] reset];
                    [MUBFileUniversalManager showOpenPanelWithType:MUBFileUniversalTypeSearchHiddenFile];
                }
                    break;
                case 3: {
                    [[MUBLogManager defaultManager] reset];
                    [MUBFileUniversalManager showOpenPanelWithType:MUBFileUniversalTypeTrashAntiImageVideoFiles];
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
                    [[MUBLogManager defaultManager] reset];
                    [[[MUBFileExtractTypeFileManager alloc] initWithTypes:@"GIF"] showOpenPanel];
                }
                    break;
                case 2: {
                    [[MUBLogManager defaultManager] reset];
                    [[[MUBFileExtractTypeFileManager alloc] initWithTypes:[MUBSettingManager defaultManager].mimeVideoTypes] showOpenPanel];
                }
                    break;
                case 3: {
                    [[MUBLogManager defaultManager] reset];
                    [[[MUBFileExtractTypeFileManager alloc] initWithTypes:nil] showOpenPanel];
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
                    [[MUBLogManager defaultManager] reset];
                    [MUBFileUniversalManager showOpenPanelWithType:MUBFileUniversalTypeRename32BitMD5ByFolder];
                }
                    break;
                case 2: {
                    [[MUBLogManager defaultManager] reset];
                    [MUBFileUniversalManager showOpenPanelWithType:MUBFileUniversalTypeRename32BitMD5ByFile];
                }
                    break;
                case 3: {
                    [[MUBLogManager defaultManager] reset];
                    [MUBFileUniversalManager showOpenPanelWithType:MUBFileUniversalTypeRename32BitMD5BySeries];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 6: {
            switch (action) {
                case 1: {
                    [[MUBLogManager defaultManager] reset];
                    [[[MUBFileSearchCharactersManager alloc] initWithCharacters:[MUBSettingManager defaultManager].fileSearchCharactersModel.OneDrive] showOpenPanel];
                }
                    break;
                case 2: {
                    [[MUBLogManager defaultManager] reset];
                    [[[MUBFileSearchCharactersManager alloc] initWithCharacters:[MUBSettingManager defaultManager].fileSearchCharactersModel.OneDrive] modifyFileNames];
                }
                    break;
                case 3: {
                    [[MUBLogManager defaultManager] reset];
                    [[[MUBFileSearchCharactersManager alloc] initWithCharacters:nil] showOpenPanel];
                }
                    break;
                case 4: {
                    [[MUBLogManager defaultManager] reset];
                    [[[MUBFileSearchCharactersManager alloc] initWithCharacters:nil] modifyFileNames];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
}


@end
