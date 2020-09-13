//
//  MUBModalWindowController.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface MUBModalWindowController : NSWindowController <NSWindowDelegate>

@property (assign) NSModalResponse modalResponse;

@end

NS_ASSUME_NONNULL_END
