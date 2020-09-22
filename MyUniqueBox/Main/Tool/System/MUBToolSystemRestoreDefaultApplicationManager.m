//
//  MUBToolSystemRestoreDefaultApplicationManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/22.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBToolSystemRestoreDefaultApplicationManager.h"

@implementation MUBToolSystemRestoreDefaultApplicationManager

+ (void)restoreWithType:(MUBToolSystemRestoreDefaultApplicationType)type applicationName:(NSString *)applicationName applicationBundleID:(NSString *)applicationBundleID {
    switch (type) {
        case MUBToolSystemRestoreDefaultApplicationTypeAudio: {
            
        }
            break;
        case MUBToolSystemRestoreDefaultApplicationTypeImage: {
            [MUBToolSystemRestoreDefaultApplicationManager _restoreWithExtensions:[MUBSettingManager defaultManager].mimeImageTypes applicationName:applicationName applicationBundleID:applicationBundleID];
        }
            break;
        case MUBToolSystemRestoreDefaultApplicationTypeVideo: {
            [MUBToolSystemRestoreDefaultApplicationManager _restoreWithExtensions:[MUBSettingManager defaultManager].mimeVideoTypes applicationName:applicationName applicationBundleID:applicationBundleID];
        }
            break;
        default:
            break;
    }
}

+ (void)_restoreWithExtensions:(NSArray *)extensions applicationName:(NSString *)applicationName applicationBundleID:(NSString *)applicationBundleID {
    for (NSInteger i = 0; i < extensions.count; i++) {
        [MUBToolSystemRestoreDefaultApplicationManager _restoreVideoExtension:extensions[i] toApplicationName:applicationName applicationBundleID:applicationBundleID];
    }
}
+ (void)_restoreVideoExtension:(NSString *)extension toApplicationName:(NSString *)applicationName applicationBundleID:(NSString *)applicationBundleID {
    CFStringRef exRef = (__bridge CFStringRef)extension;
    CFStringRef exUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, exRef, NULL);
    
    CFURLRef helperApplicationURL = LSCopyDefaultApplicationURLForContentType(exUTI, kLSRolesAll, NULL);
    if (helperApplicationURL == NULL) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"类型: %@ 未注册到系统的 Launch Services 中，跳过", extension];
        return;
    }
    
    // Check to make sure the registered helper application isn't us
    NSString *helperApplicationPath = [(__bridge NSURL *)helperApplicationURL path];
    NSString *helperApplicationName = [[NSFileManager defaultManager] displayNameAtPath:helperApplicationPath];
    
    if ([helperApplicationName isEqualToString:applicationName]) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"类型: %@ 默认打开方式为: %@，跳过", extension, applicationName];
    } else {
        LSSetDefaultRoleHandlerForContentType(exUTI, kLSRolesAll, (__bridge CFStringRef)applicationBundleID);
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"类型: %@ 原打开方式为: %@，已修改为: %@", extension, helperApplicationName, applicationName];
    }
    
    CFRelease(helperApplicationURL);
}

@end
