//
//  DefaultTextChatTableViewController.m
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "TextChatTableViewController.h"
#import "OTTextChat.h"

#import "AppDelegate.h"

@interface TextChatTableViewController () <OTTextChatTableViewDataSource, OTTextChatDataSource, UITextFieldDelegate> {
    NSUInteger maximumTextMessageLength;
    UILabel *countLabel;
}
@property (nonatomic) OTTextChat *textChat;
@property (nonatomic) NSMutableArray *textMessages;
@end

@implementation TextChatTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    maximumTextMessageLength = 120;
    
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
    [self configureCountLabel];
}

- (void)sendTextMessage {
    [self.textChat sendMessage:self.textChatInputView.textField.text];
    [self updateLabel:0];
}

- (void)configureCountLabel {
    countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    countLabel.translatesAutoresizingMaskIntoConstraints = NO;
    countLabel.text = [NSString stringWithFormat:@"%@", @(maximumTextMessageLength)];
    countLabel.textAlignment = NSTextAlignmentCenter;
    countLabel.font = [UIFont systemFontOfSize:10.0f];
    [self.textChatInputView.textField addSubview:countLabel];
    
    [NSLayoutConstraint constraintWithItem:countLabel
                                 attribute:NSLayoutAttributeTrailing
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.textChatInputView.textField
                                 attribute:NSLayoutAttributeTrailing
                                multiplier:1.0
                                  constant:-2.0].active = YES;
    [NSLayoutConstraint constraintWithItem:countLabel
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.textChatInputView.textField
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1.0
                                  constant:0.0].active = YES;
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Allow a backspace always, in case we went over inputMaxChars
    const char *_char = [string cStringUsingEncoding:NSUTF8StringEncoding];
    if (strcmp(_char, "\b") == -8) {
        [self updateLabel:[textField.text length] - 1];
        return YES;
    }
    
    // If it's not a backspace, allow it if we're still under 150 chars.
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    [self updateLabel: newLength];
    return (newLength >= maximumTextMessageLength) ? NO : YES;
}


-(void)updateLabel:(NSUInteger)Charlength {
    countLabel.textColor = [UIColor blackColor];
    
    NSUInteger charLeft = maximumTextMessageLength - Charlength;
    NSUInteger closeEnd = round(maximumTextMessageLength * .1);
    if (closeEnd >= 100) closeEnd = 30;
    if (charLeft <= closeEnd) {
        countLabel.textColor = [UIColor redColor];
        countLabel.textColor = [UIColor redColor];
    }
    NSString* charCountStr = [NSString stringWithFormat:@"%lu", (unsigned long)charLeft];
    countLabel.text = charCountStr;
}

#pragma mark - OTTextChatDataSource
- (OTAcceleratorSession *)sessionOfOTTextChat:(OTTextChat *)textChat {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return appDelegate.acceleratorSession;
}

@end
