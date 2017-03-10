//
//  DefaultTextChatTableViewController.m
//
//  Copyright © 2017 Tokbox, Inc. All rights reserved.
//

#import "TextChatTableViewController.h"
#import "OTTextChat.h"

#import "AppDelegate.h"

@interface TextChatTableViewController () <OTTextChatTableViewDataSource, OTTextChatDataSource, UITextFieldDelegate>
@property (nonatomic) OTTextChat *textChat;
@property (nonatomic) NSMutableArray *textMessages;
@end

@implementation TextChatTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textChat = [[OTTextChat alloc] init];
    self.textChat.dataSource = self;
    self.textChat.alias = @"Tokboxer";
    self.textMessages = [[NSMutableArray alloc] init];
    
    self.textChatNavigationBar.topItem.title = self.textChat.alias;
    self.tableView.textChatTableViewDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.textChatInputView.textField.delegate = self;
    
    __weak TextChatTableViewController *weakSelf = self;
    [self.textChat connectWithHandler:^(OTTextChatConnectionEventSignal signal, OTConnection *connection, NSError *error) {
        if (signal == OTTextChatConnectionEventSignalDidConnect) {
            NSLog(@"Text Chat starts");
        }
        else if (signal == OTTextChatConnectionEventSignalDidDisconnect) {
            NSLog(@"Text Chat stops");
        }
    } messageHandler:^(OTTextChatMessageEventSignal signal, OTTextMessage *message, NSError *error) {
        
        if (signal == OTTextChatMessageEventSignalDidSendMessage || signal == OTTextChatMessageEventSignalDidReceiveMessage) {
            
            if (!error) {
                [weakSelf.textMessages addObject:message];
                [weakSelf.tableView reloadData];
                weakSelf.textChatInputView.textField.text = nil;
                [weakSelf scrollTextChatTableViewToBottom];
            }
        }
    }];
    
    [self.textChatInputView.sendButton addTarget:self action:@selector(sendTextMessage) forControlEvents:UIControlEventTouchUpInside];
}

- (void)sendTextMessage {
    [self.textChat sendMessage:self.textChatInputView.textField.text];
}

#pragma mark - OTTextChatTableViewDataSource
- (OTTextChatViewType)typeOfTextChatTableView:(OTTextChatTableView *)tableView {
    
    return OTTextChatViewTypeDefault;
}

- (NSInteger)textChatTableView:(OTTextChatTableView *)tableView
         numberOfRowsInSection:(NSInteger)section {
    
    return self.textMessages.count;
}

- (OTTextMessage *)textChatTableView:(OTTextChatTableView *)tableView
          textMessageItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.textMessages[indexPath.row];
}

- (UITableViewCell *)textChatTableView:(OTTextChatTableView *)tableView
                 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return nil;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self sendTextMessage];
    return YES;
}

#pragma mark - OTTextChatDataSource
- (OTAcceleratorSession *)sessionOfOTTextChat:(OTTextChat *)textChat {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return appDelegate.acceleratorSession;
}

@end
