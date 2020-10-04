//
//  MUBResourceExHentaiModels.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/10/02.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBModel.h"

NS_ASSUME_NONNULL_BEGIN

@class MUBResourceExHentaiTorrentModel;

@interface MUBResourceExHentaiPageModel : MUBModel

@property (assign) NSInteger dgid;

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
@property (copy) NSArray<MUBResourceExHentaiTorrentModel *> *torrents;
@property (copy) NSString *uploader;
@property (copy) NSString *trackerID;

@end

@interface MUBResourceExHentaiTorrentModel : MUBModel

@property (copy) NSString *tHash;
@property (assign) NSTimeInterval added;
@property (copy) NSString *name;
@property (assign) double tsize;
@property (assign) double fsize;
@property (copy) NSString *URL;

@end

@interface MUBResourceExHentaiImageModel : MUBModel

@property (copy) NSString *downloadURL;
@property (nonatomic, copy) NSString *pageURL;
@property (copy) NSString *pageToken;

@end

NS_ASSUME_NONNULL_END
