//
//  MUBDownloadOperation.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/23.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MUBDownloadOperation : NSOperation

+ (instancetype)operationWithURLSessionTask:(NSURLSessionTask *)task;

@end

NS_ASSUME_NONNULL_END
