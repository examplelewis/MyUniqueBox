//
//  MUBAlert.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MUBAlert : NSAlert

@property (assign) NSModalResponse response;

- (void)addButtonWithTitles:(NSArray *)titles keyEquivalents:(NSArray *)keyEquivalents;

@end

NS_ASSUME_NONNULL_END
