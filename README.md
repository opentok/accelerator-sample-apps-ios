![logo](./tokbox-logo.png)

# Accelerator Sample App for iOS

## Quick start

This section shows you how to prepare, build, and run the sample application. This app is built using [accelerator-core-ios](https://github.com/opentok/accelerator-core-ios).

### Install the project files

Use CocoaPods to install the project files and dependencies.

1. Install CocoaPods as described in [CocoaPods Getting Started](https://guides.cocoapods.org/using/getting-started.html#getting-started).
1. In Terminal, `cd` to your project directory and type `pod install`.
1. Reopen your project in Xcode using the new `*.xcworkspace` file.

### Configure and build the app

Configure the sample app code. Then, build and run the app.

1. The application **requires** values for **API Key**, **Session ID**, and **Token**. In the sample, you can get these values at the [OpenTok Developer Dashboard](https://dashboard.tokbox.com/). For production deployment, you must generate the **Session ID** and **Token** values using one of the [OpenTok Server SDKs](https://tokbox.com/developer/sdks/server/).

1. Replace the following empty strings with the corresponding **API Key**, **Session ID**, and **Token** values:

    ```objc
    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.acceleratorSession = [[OTAcceleratorSession alloc] initWithOpenTokApiKey:<#apikey#>
                                                                        sessionId:<#sessionid#>
                                                                            token:<#token#>];
    return YES;
}
    ```

1. Use Xcode to build and run the app on an iOS simulator or device.

## Exploring the code

For details about developing with the SDK and the APIs this sample uses, see the [OpenTok iOS SDK Requirements](https://tokbox.com/developer/sdks/ios/) and the [OpenTok iOS SDK Reference](https://tokbox.com/developer/sdks/ios/reference/).

_**NOTE:** This sample app collects anonymous usage data for internal TokBox purposes only. Please do not modify or remove any logging code from this sample application._


###Call

When the call button is pressed `OTMultiPartyCommunicator` initiates the connection to the OpenTok session and sets up the listeners for the publisher and subscriber streams:


   ```objc
- (IBAction)publisherCallButtonPressed:(UIButton *)sender {
    
    if (!self.multipartyCommunicator.isCallEnabled) {
        [SVProgressHUD show];

        __weak MainViewController *weakSelf = self;
        [self.multipartyCommunicator connectWithHandler:^(OTCommunicationSignal signal, OTMultiPartyRemote *subscriber, NSError *error) {
            weakSelf.multipartyCommunicator.publisherView.showAudioVideoControl = NO;
            if (!error) {
                [weakSelf handleCommunicationSignal:signal remote:subscriber];
            }
            else {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }
        }];
    }
    else {
        [SVProgressHUD popActivity];
        [self.multipartyCommunicator disconnect];
        [self.mainView resetAllControl];
    }
}
   ```
The remote connection to the subscriber is handled according to the signal obtained:

   ```objc
- (void)handleCommunicationSignal:(OTCommunicationSignal)signal
                           remote:(OTMultiPartyRemote *)remote {
   
    switch (signal) {
		...
            case OTSubscriberVideoEnabledByPublisher:{
            remote.subscribeToVideo = YES;
            break;
        }
        case OTSubscriberVideoDisableWarning:{
            remote.subscribeToVideo = NO;
            break;
        }
        case OTSubscriberVideoDisableWarningLifted:{
            remote.subscribeToVideo = YES;
            break;
        }
        default: break;
    }
}
   ``` 
   
### TextChat

The **TextCHat** feature is built using [accelerator-textchat-ios](https://github.com/opentok/accelerator-textchat-ios). When the text message button is pressed the view changes to present the chat UI:

   ```objc
- (IBAction)textMessageButtonPressed:(id)sender {
    [self presentViewController:[[TextChatTableViewController alloc] init] animated:YES completion:nil]; //When the text message button is pressed the view changes to present the chat UI
}
   ```
The textchat implementation is pre-configured with values, you can change the default values like `maximumTextMessageLength` and `alias` in `TextChatTableViewController`:

   ```objc
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
   ``` 

###ScreenShare

The **screen share** features shares images from your camera roll using the `ScreenShareViewController` class which publishes the content.

   ```objc
- (void)startScreenSharing {
    self.multipartyScreenSharer = [[OTMultiPartyCommunicator alloc] initWithView:self.annotationView];
    self.multipartyScreenSharer.publishOnly = YES;
    self.multipartyScreenSharer.dataSource = self;
    __weak ScreenShareViewController *weakSelf = self;
    [self.multipartyScreenSharer connectWithHandler:^(OTCommunicationSignal signal, OTMultiPartyRemote *subscriber, NSError *error) {
        
        if (error) {
            [weakSelf dismissViewControllerAnimated:YES completion:^(){
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }];
            return;
        }
        
        if (signal == OTPublisherCreated) {
            
            weakSelf.multipartyScreenSharer.publishAudio = NO;
            [weakSelf startAnnotation];
        }
    }];
}
   ```
   
###Annotation

The `ScreenShareViewController` class also handles annotation:

   ```objc
- (void)startAnnotation {
    self.annotator = [[OTAnnotator alloc] init];
    self.annotator.dataSource = self;
    __weak ScreenShareViewController *weakSelf = self;
    [self.annotator connectWithCompletionHandler:^(OTAnnotationSignal signal, NSError *error) {
        if (error) {
            [weakSelf dismissViewControllerAnimated:YES completion:^(){
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }];
            return;
        }
        
        if (signal == OTAnnotationSessionDidConnect) {
            
            // using frame and self.view to contain toolbarView is for having more space to interact with color picker
            [weakSelf.annotator.annotationScrollView initializeToolbarView];
            weakSelf.annotator.annotationScrollView.toolbarView.toolbarViewDataSource = self;
            weakSelf.annotator.annotationScrollView.toolbarView.frame = weakSelf.annotationToolbarView.frame;
            [weakSelf.view addSubview:weakSelf.annotator.annotationScrollView.toolbarView];
            
            weakSelf.annotator.annotationScrollView.frame = weakSelf.annotationView.bounds;
            weakSelf.annotator.annotationScrollView.scrollView.contentSize = CGSizeMake(CGRectGetWidth(weakSelf.annotator.annotationScrollView.bounds), CGRectGetHeight(weakSelf.annotator.annotationScrollView.bounds));
            [weakSelf.annotationView addSubview:weakSelf.annotator.annotationScrollView];
            
            weakSelf.annotator.annotationScrollView.annotatable = NO;
        }
    }];
}
   ```
   
It also provides a method to get the session of the annotator:

   ```objc
- (OTAcceleratorSession *)sessionOfOTAnnotator:(OTAnnotator *)annotator {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return appDelegate.acceleratorSession;
}   
   ```    
