//
//  MUBFileDispatchManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 21/05/15.
//  Copyright © 2021 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MUBFileDispatchManager : NSObject

#pragma mark - Dispatch
+ (void)operationDispatchByOperationID:(NSInteger)oID;

@end

NS_ASSUME_NONNULL_END
