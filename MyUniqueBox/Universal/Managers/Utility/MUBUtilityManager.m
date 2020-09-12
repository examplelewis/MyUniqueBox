//
//  MUBUtilityManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBUtilityManager.h"

@implementation MUBUtilityManager

+ (NSString *)humanReadableTimeFromInterval:(NSTimeInterval)interval {
    NSInteger minutes = interval / 60;
    NSInteger seconds = floor(interval - minutes * 60);
    NSInteger milliseconds = (NSInteger)floor(interval * 1000) % 1000;
    return [NSString stringWithFormat:@"%02ld:%02ld.%03ld", minutes, seconds, milliseconds];
}

@end
