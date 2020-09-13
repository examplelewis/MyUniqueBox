//
//  MUBMenuItemFileManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBMenuItemFileManager.h"

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
        case 2: {
            switch (action) {
                case 1: {
                    
                }
                    break;
                case 2: {
                    
                }
                    break;
                case 3: {
                    
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
                    
                }
                    break;
                case 2: {
                    
                }
                    break;
                case 3: {
                    
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
        case 6: {
            switch (action) {
                case 1: {
                    
                }
                    break;
                case 2: {
                    
                }
                    break;
                case 3: {
                    
                }
                    break;
                case 4: {
                    
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
