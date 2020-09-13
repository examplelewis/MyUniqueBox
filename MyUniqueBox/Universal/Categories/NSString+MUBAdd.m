//
//  NSString+MUBAdd.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "NSString+MUBAdd.h"

@implementation NSString (MUBAdd)

- (BOOL)isNotNull {
    return self && [self isKindOfClass:[NSString class]] && self.length > 0;
}

@end
