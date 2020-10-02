//
//  MUBResourceExHentaiModels.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/10/02.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MUBResourceExHentaiPageModel : MUBModel

@property (copy) NSString *archiverKey;
@property (copy) NSString *category;
@property (assign) float expunged;
@property (assign) NSInteger filecount;
@property (assign) NSInteger filesize;
@property (assign) NSInteger gid;
@property (assign) NSInteger posted;
@property (copy) NSString *rating;
@property (copy) NSArray *tags;
@property (copy) NSString *thumb;
@property (copy) NSString *title;
@property (copy) NSString *titleJpn;
@property (copy) NSString *token;
@property (assign) NSInteger torrentcount;
@property (copy) NSArray *torrents;
@property (copy) NSString *uploader;

@end

NS_ASSUME_NONNULL_END
