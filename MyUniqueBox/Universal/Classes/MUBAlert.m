//
//  MUBAlert.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBAlert.h"

@implementation MUBAlert

- (void)addButtonWithTitles:(NSArray *)titles keyEquivalents:(NSArray *)keyEquivalents {
    NSInteger buttonsCount = MIN(titles.count, keyEquivalents.count);
    for (NSInteger i = 0; i < buttonsCount; i++) {
        [self addButtonWithTitle:titles[i]];
        self.buttons[i].keyEquivalent = keyEquivalents[i];
    }
}

@end
