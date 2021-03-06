//
//  MUBConstHeader.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#ifndef MUBConstHeader_h
#define MUBConstHeader_h

typedef NS_OPTIONS(NSUInteger, MUBFileOpertaionBehavior) {
    MUBFileOpertaionBehaviorNone            = 0,
    MUBFileOpertaionBehaviorShowSuccessLog  = 1 << 0,
    MUBFileOpertaionBehaviorShowNoneLog     = 1 << 1,
    MUBFileOpertaionBehaviorExportNoneLog     = 1 << 2,
};

// Time Format
static NSString * const MUBTimeFormatCompactyMd = @"yyyyMMdd";
static NSString * const MUBTimeFormatyMdHms = @"yyyy-MM-dd HH:mm:ss";
static NSString * const MUBTimeFormatyMdHmsS = @"yyyy-MM-dd HH:mm:ss.SSS";
static NSString * const MUBTimeFormatEMdHmsZy = @"EEE MMM dd HH:mm:ss Z yyyy";

static NSString * const MUBTimeFormatyMdHmsCompact = @"yyyyMMddHHmmss";

// Notification Key
static NSString * const MUBDidGetWeiboTokenNotification = @"com.gongyu.MyUniqueBox.MUBDidGetWeiboTokenNotification";

// Warning
static NSString * const MUBWarningNoneContentFoundInInputTextView = @"没有获得任何输入内容，请检查输入框";

#endif /* MUBConstHeader_h */
