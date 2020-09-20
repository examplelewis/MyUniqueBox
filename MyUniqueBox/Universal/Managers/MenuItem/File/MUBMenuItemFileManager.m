//
//  MUBMenuItemFileManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBMenuItemFileManager.h"
#import "MUBFileUniversalManager.h"
#import "MUBFileSearchCharactersManager.h"
#import "MUBFileExtractTypeFileManager.h"

static NSInteger const kDefaultTag = 3000000;

@implementation MUBMenuItemFileManager

+ (void)customMenuItemDidPress:(NSMenuItem *)sender {
    NSInteger type = (sender.tag - kDefaultTag) / 100;
    NSInteger action = (sender.tag - kDefaultTag) % 100;
    
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
                    [MUBFileUniversalManager showOpenPanelWithType:MUBFileUniversalTypeCopyFolderHierarchy];
                }
                    break;
                case 2: {
                    [MUBFileUniversalManager showOpenPanelWithType:MUBFileUniversalTypeExtractSingleFolder];
                }
                    break;
                case 3: {
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
                    [MUBFileUniversalManager showOpenPanelWithType:MUBFileUniversalTypeRenameAsSuperFodlerNameOnSingleFolder];
                }
                    break;
                case 2: {
                    [MUBFileUniversalManager showOpenPanelWithType:MUBFileUniversalTypeRenameAsSuperFodlerNameOnSingleFile];
                }
                    break;
                case 3: {
                    [MUBFileUniversalManager showOpenPanelWithType:MUBFileUniversalTypeRenameAsSuperFodlerNameOnSingleContent];
                }
                    break;
                case 4: {
                    [MUBFileUniversalManager showOpenPanelWithType:MUBFileUniversalTypeRenameAddSuperFolderNameOnAllFolders];
                }
                    break;
                case 5: {
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
                    
                }
                    break;
                case 2: {
                    [MUBFileUniversalManager showOpenPanelWithType:MUBFileUniversalTypeSearchHiddenFile];
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
                    [[[MUBFileExtractTypeFileManager alloc] initWithTypes:@"GIF"] showOpenPanel];
                }
                    break;
                case 2: {
                    [[[MUBFileExtractTypeFileManager alloc] initWithTypes:[MUBSettingManager defaultManager].mimeVideoTypes] showOpenPanel];
                }
                    break;
                case 3: {
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
                    [MUBFileUniversalManager showOpenPanelWithType:MUBFileUniversalTypeRename32BitMD5ByFolder];
                }
                    break;
                case 2: {
                    [MUBFileUniversalManager showOpenPanelWithType:MUBFileUniversalTypeRename32BitMD5ByFile];
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
                    [[[MUBFileSearchCharactersManager alloc] initWithCharacters:[MUBSettingManager defaultManager].fileSearchCharactersModel.OneDrive] showOpenPanel];
                }
                    break;
                case 2: {
                    [[[MUBFileSearchCharactersManager alloc] initWithCharacters:[MUBSettingManager defaultManager].fileSearchCharactersModel.OneDrive] modifyFileNames];
                }
                    break;
                case 3: {
                    [[[MUBFileSearchCharactersManager alloc] initWithCharacters:nil] showOpenPanel];
                }
                    break;
                case 4: {
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
