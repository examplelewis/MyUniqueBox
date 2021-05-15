//
//  MUBFileWindowController.m
//  MyUniqueBox
//
//  Created by 龚宇 on 21/05/14.
//  Copyright © 2021 龚宇. All rights reserved.
//

#import "MUBFileWindowController.h"
#import "MUBFileDispatchManager.h"

@interface MUBFileWindowController () <NSTableViewDelegate, NSTableViewDataSource>

@property (strong) IBOutlet NSTextField *contentPathLabel;
@property (strong) IBOutlet NSTextView *contentPathTextView;
@property (strong) IBOutlet NSButton *startButton;
@property (strong) IBOutlet NSTextField *keywordsLabel;
@property (strong) IBOutlet NSTableView *tableView;
@property (strong) IBOutlet NSTextView *descTextView;

@property (strong) NSMutableArray<MUBFileOperationModel *> *models;

@property (strong) MUBFileOperationModel *selectedModel;

@end

@implementation MUBFileWindowController

#pragma mark - Lifecycle
- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self setupUIAndData];
}

#pragma mark - Configure
- (void)setupUIAndData {
    // Data
    self.models = [NSMutableArray array];
    [self fetchAllOperations];
    
    // UI
    self.startButton.enabled = NO;
}

#pragma mark - Database
- (void)fetchAllOperations {
    // 从数据库读取数据
    self.models = [MUBSQLiteManager defaultManager].fileOperationModelsInDatabase;
    
    // 生成分隔行
    NSArray *oIDs = [self.models valueForKey:@"oID"];
    oIDs = [oIDs bk_map:^NSNumber *(NSNumber *oID) {
        return @(oID.integerValue / 100);
    }];
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:oIDs];
    oIDs = orderedSet.array;
    NSArray *separatorModels = [oIDs bk_map:^MUBFileOperationModel *(NSNumber *oID) {
        return [MUBFileOperationModel separatorModelForID:oID.integerValue * 100];
    }];
    separatorModels = [separatorModels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"oID != 0"]];
    
    // 添加分隔行
    [self.models addObjectsFromArray:separatorModels];
    [self.models sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"oID" ascending:YES]]];
    
    // 刷新列表
    [self.tableView reloadData];
}

#pragma mark - IBActions
- (IBAction)filePanelButtonDidPress:(NSButton *)sender {
    
}
- (IBAction)startButtonDidPress:(NSButton *)sender {
    [MUBFileDispatchManager operationDispatchByOperationID:self.selectedModel.oID];
}
- (IBAction)refreshButtonDidPress:(NSButton *)sender {
    [self fetchAllOperations];
}
- (IBAction)saveDescButtonDidPress:(NSButton *)sender {
    if ([self.selectedModel.oDesc isEqualToString:self.descTextView.string]) {
        return;
    }
    
    NSString *newDesc = self.descTextView.string.copy;
    BOOL success = [[MUBSQLiteManager defaultManager] updateFileOperationDescription:newDesc forModelID:self.selectedModel.oID];
    if (success) {
        self.selectedModel.oDesc = self.descTextView.string;
        self.models[self.tableView.selectedRow].oDesc = self.descTextView.string;
        
        [self.tableView reloadData];
    }
}
- (IBAction)tableViewDidDoubleClick:(NSTableView *)sender {
    // do nothing...
    // 只是不让tableView在双击之后编辑行内容
}

#pragma mark - UI
- (void)examineConditions {
    self.startButton.enabled = [self startButtonEnabled];
}
- (BOOL)startButtonEnabled {
    if (!self.selectedModel) {
        return NO;
    }
    if (self.contentPathLabel.stringValue.length == 0 && self.contentPathTextView.string.length == 0) {
        return NO;
    }
    
    return YES;
}

#pragma mark - NSTabViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.models.count;
}
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return self.models[row].title;
}

#pragma mark - NSTableViewDelegate
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    return self.models[row].level >= MUBFileOperationLevelEnabledButNotTest;
}
- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    self.selectedModel = self.models[self.tableView.selectedRow];
    
    self.keywordsLabel.stringValue = self.selectedModel.keywordsStr ?: @"没有关键字";
    self.descTextView.string = self.selectedModel.oDesc ?: @"没有写内容";
    
    [self examineConditions];
}

@end
