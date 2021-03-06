//
//  NSColor+MUBAdd.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "NSColor+MUBAdd.h"

@implementation NSColor (MUBAdd)

+ (NSColor *)colorWithHexString:(NSString *)hexString {
    NSString *cString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([cString hasPrefix:@"0X"] && cString.length >= 2) {
        cString = [cString substringFromIndex:2];
    }
    if ([cString hasPrefix:@"#"] && cString.length >= 1) {
        cString = [cString substringFromIndex:1];
    }
    if (cString.length != 6 && cString.length != 8) {
        [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"颜色值出错: %@，返回透明", hexString];
        return [NSColor clearColor];
    }
    
    unsigned int r, g, b;
    unsigned int a = 1;
    
    NSString *rString = [cString substringWithRange:NSMakeRange(0, 2)];
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    NSString *gString = [cString substringWithRange:NSMakeRange(2, 2)];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    NSString *bString = [cString substringWithRange:NSMakeRange(4, 2)];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    if (cString.length == 8) {
        NSString *aString = [cString substringWithRange:NSMakeRange(6, 2)];
        [[NSScanner scannerWithString:aString] scanHexInt:&a];
    }
    
    return [NSColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:a / 255.0f];
}

@end
