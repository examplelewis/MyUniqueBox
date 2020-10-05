//
//  MUBSQLiteExHentaiManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/10/04.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "MUBSQLiteExHentaiManager.h"
#import <fmdb/FMDB.h>

@interface MUBSQLiteExHentaiManager ()

@property (strong) FMDatabaseQueue *queue;
@property (strong) NSArray *hentaiFoundryExceptions; // HentaiFoundry的关注用户，不获取他们的数据
@property (strong) NSArray *specialFocusArtists; // 特别关注的画师

@end

@implementation MUBSQLiteExHentaiManager

#pragma mark - Lifecycle
+ (instancetype)defaultManager {
    static MUBSQLiteExHentaiManager *defaultManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [[self alloc] init];
        defaultManager.queue = [FMDatabaseQueue databaseQueueWithPath:[[MUBSettingManager defaultManager] pathOfContentInMainDatabasesFolder:MUBSQLiteExHentaiFileName]];
        [defaultManager _readData];
    });
    
    return defaultManager;
}

#pragma mark - Configure
- (void)_readData {
    NSMutableArray *hentaiFoundryExceptions = [NSMutableArray array];
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *rs = [db executeQuery:@"select value from MUBArtistsException"];
        while ([rs next]) {
            [hentaiFoundryExceptions addObject:[rs stringForColumnIndex:0]];
        }
        [rs close];
    }];
    self.hentaiFoundryExceptions = hentaiFoundryExceptions.copy;
    
    NSMutableArray *specialFocusArtists = [NSMutableArray array];
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
            
    }];
    self.specialFocusArtists = specialFocusArtists.copy;
}

#pragma mark - ExHentai
- (NSInteger)getDGIDWithExHentaiPageModel:(MUBResourceExHentaiPageModel *)model {
    BOOL foundHentaiFoundaryException = NO;
    for (NSString *hentai in self.hentaiFoundryExceptions) {
        if ([model.title rangeOfString:hentai options:NSCaseInsensitiveSearch].location != NSNotFound) {
            foundHentaiFoundaryException = YES;
            break;
        }
    }
    if (foundHentaiFoundaryException) {
        return MUBErrorCodeSQLiteExHentaiHentaiFoundaryExceptionFound;
    }
    
    __block NSInteger dgid = -1;
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *query = [NSString stringWithFormat:@"select dgid from MUBDownloadGallery where title = '%@' and uploader = '%@'", model.title, model.uploader];
        FMResultSet *rs = [db executeQuery:query];
        while ([rs next]) {
            dgid = [rs intForColumnIndex:0];
        }
        [rs close];
    }];
    if (dgid != -1) {
        return dgid;
    }
    
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *rs = [db executeQuery:@"select value from MUBConst where type = 1"];
        while ([rs next]) {
            dgid = [rs intForColumnIndex:0];
        }
        [rs close];
    }];
    dgid += 1;
    
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL success = [db executeUpdate:@"UPDATE MUBConst SET value = ? WHERE type = 1", @(dgid)];
        if (success) {
            [[MUBLogManager defaultManager] addDefaultLogWithFormat:@"更新 MUBConst DGID: %ld 成功", dgid];
        } else {
            [[MUBLogManager defaultManager] addErrorLogWithFormat:@"更新 MUBConst DGID: %ld 时发生错误：%@", dgid, [db lastErrorMessage]];
        }
    }];
    
    return dgid;
}
- (NSArray<MUBResourceExHentaiImageModel *> *)filteredExHentaiImageModelsFrom:(NSArray<MUBResourceExHentaiImageModel *> *)imageModels model:(MUBResourceExHentaiPageModel *)model {
    NSMutableArray *storedPageTokens = [NSMutableArray array];
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *query = [NSString stringWithFormat:@"select page_token from MUBDownloadImage where dgid = %ld", model.dgid];
        FMResultSet *rs = [db executeQuery:query];
        while ([rs next]) {
            [storedPageTokens addObject:[rs stringForColumnIndex:0]];
        }
        [rs close];
    }];
    
    return [imageModels bk_select:^BOOL(MUBResourceExHentaiImageModel *obj) {
        return ![storedPageTokens containsObject:obj.pageToken];
    }];
}
- (void)insertExHentaiImageModels:(NSArray<MUBResourceExHentaiImageModel *> *)imageModels model:(MUBResourceExHentaiPageModel *)model downloadFolderPath:(NSString *)downloadFolderPath {
    NSTimeInterval nowInterval = [[NSDate date] timeIntervalSince1970];
    NSString *nowReadable = [[NSDate date] formattedDateWithFormat:MUBTimeFormatyMdHms];
    
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *update = @"INSERT INTO MUBDownloadGallery (dgid, gid, start_page, end_page, fetch_count, download_count, remark, category, filecount, filesize, posted, title, titleJpn, token, uploader, fetch_time, fetch_readable_time, fetch_gallery_url) values(?, ? ,?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        NSArray *arguments = @[@(model.dgid), @(model.gid), @(model.startPage), @(model.endPage), @(model.fetchCount), @(model.downloadCount), model.remark, model.category, @(model.filecount), @(model.filesize), @(model.posted), model.title, model.titleJpn, model.token, model.uploader, @(nowInterval), nowReadable, [NSString stringWithFormat:@"https://exhentai.org/g/%ld/%@/", model.gid, model.token]];
        
        if (![db executeUpdate:update withArgumentsInArray:arguments]) {
            [[MUBLogManager defaultManager] addErrorLogWithFormat:@"往数据表:MUBDownloadGallery中插入数据时发生错误：%@", [db lastErrorMessage]];
            [[MUBLogManager defaultManager] addErrorLogWithFormat:@"插入的数据：%@", model];
        }
    }];
    
    for (MUBResourceExHentaiImageModel *imageModel in imageModels) {
        [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
            NSString *update = @"INSERT INTO MUBDownloadImage (pid, dgid, gid, page_token, image_url, save_path, save_time, save_readable_time) values(?, ?, ?, ?, ?, ?, ?, ?)";
            NSArray *arguments = @[[NSNull null], @(model.dgid), @(model.gid), imageModel.pageToken, imageModel.downloadURL, downloadFolderPath, @(nowInterval), nowReadable];
            
            if (![db executeUpdate:update withArgumentsInArray:arguments]) {
                [[MUBLogManager defaultManager] addErrorLogWithFormat:@"往数据表:MUBDownloadImage中插入数据时发生错误：%@", [db lastErrorMessage]];
                [[MUBLogManager defaultManager] addErrorLogWithFormat:@"插入的数据：%@", imageModel];
            }
        }];
    }
}
- (NSString *)pageURLWithGalleryID:(NSInteger)gid {
    __block NSString *pageURL = @"";
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *query = [NSString stringWithFormat:@"select fetch_gallery_url from MUBDownloadGallery where gid = %ld", gid];
        FMResultSet *rs = [db executeQuery:query];
        while ([rs next]) {
            pageURL = [rs stringForColumnIndex:0];
        }
        [rs close];
    }];
    
    return pageURL;
}

@end
