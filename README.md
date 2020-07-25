# Accelerator Sample App for iOS

<img src="https://assets.tokbox.com/img/vonage/Vonage_VideoAPI_black.svg" height="48px" alt="Tokbox is now known as Vonage" />

## Quick start

This app is built using [accelerator-core-ios](https://github.com/opentok/accelerator-core-ios) and the following accelerator packs:

- [TextChat](https://github.com/opentok/accelerator-textchat-ios)
- [Annotation](https://github.com/opentok/accelerator-annotation-ios)

### Install the project files

Use CocoaPods to install the project files and dependencies.

1. Install CocoaPods as described in [CocoaPods Getting Started](https://guides.cocoapods.org/using/getting-started.html#getting-started).
1. In Terminal, `cd` to your project directory and type `pod install`. (Sometimes, `pod update` is magical)
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
    ```swift
     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        session = OTAcceleratorSession.init(openTokApiKey: <#apikey#>, sessionId: <#sessionid#>, token: <#token#>)
        return true
    }
    ```

1. Use Xcode to build and run the app on an iOS simulator or device.

## Exploring the code

This section shows you how to prepare, build, and run the sample application. Example code is added in [Objective-C](https://github.com/opentok/accelerator-sample-apps-ios/tree/master/AcceleratorSample) and [Swift](https://github.com/opentok/accelerator-sample-apps-ios/tree/master/AcceleratorSampleApp-Swift). With the sample application you can:

- [Start a Audio/Video Call](#call)
- [Send text messages](#textchat)
- [Share your screen](#screenshare)
- [Annotate on the screen](#annotation)

For details about developing with the SDK and the APIs this sample uses, see the [OpenTok iOS SDK Requirements](https://tokbox.com/developer/sdks/ios/) and the [OpenTok iOS SDK Reference](https://tokbox.com/developer/sdks/ios/reference/).

_**NOTE:** This sample app collects anonymous usage data for internal TokBox purposes only. Please do not modify or remove any logging code from this sample application._


###Call

When the call button is pressed `OTMultiPartyCommunicator` initiates the connection to the OpenTok session and sets up the listeners for the publisher and subscriber streams:


```objc
// start call
[SVProgressHUD show];
__weak MainViewController *weakSelf = self;
[self.multipartyCommunicator connectWithHandler:^(OTCommunicationSignal signal, OTMultiPartyRemote *subscriber, NSError *error) {
    if (!error) {
        [weakSelf handleCommunicationSignal:signal remote:subscriber];
    }
    else {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }
}];
```

```swift
// start call
SVProgressHUD.show()
multipartyCommunicator.connect {
    [unowned self] (signal, remote, error) in
    
    guard error == nil else {
        SVProgressHUD.showError(withStatus: error!.localizedDescription)
        return
    }
    self.handleCommunicationSignal(signal, remote: remote)
}
```


The remote connection to the subscriber is handled according to the signal obtained:

```objc
- (void)handleCommunicationSignal:(OTCommunicationSignal)signal
                        remote:(OTMultiPartyRemote *)remote {
    switch (signal) {
        case OTPublisherCreated: {  // join a call
            [SVProgressHUD popActivity];
            self.multipartyCommunicator.publisherView.showAudioVideoControl = NO;
            [self.mainView enableControlButtonsForCall:YES];
            [self.mainView connectCallHolder:self.multipartyCommunicator.isCallEnabled];
            [self.mainView addPublisherView:self.multipartyCommunicator.publisherView];
            break;
        }
        case OTSubscriberCreated: { // one participant is ready to join
            [SVProgressHUD show];
        }
        case OTSubscriberReady: {   // one participant joins
            [SVProgressHUD popActivity];
            if (![self.subscribers containsObject:remote]) {
                [self.subscribers addObject:remote];
                [self.mainView updateSubscriberViews:self.subscribers
                                       publisherView:self.multipartyCommunicator.publisherView];
            }
            break;
        }
        case OTSubscriberDestroyed:{    // one participant leaves
            if ([self.subscribers containsObject:remote]) {
                [self.subscribers removeObject:remote];
                [self.mainView updateSubscriberViews:self.subscribers
                                       publisherView:self.multipartyCommunicator.publisherView];
            }
            break;
        }
        ...
    }
}
``` 

```swift
fileprivate func handleCommunicationSignal(_ signal: OTCommunicationSignal, remote: OTMultiPartyRemote?) {
    switch signal {
    case .publisherCreated: // join a call
        
        guard let multipartyCommunicator = multipartyCommunicator else {break}
        SVProgressHUD.popActivity()
        multipartyCommunicator.publisherView.showAudioVideoControl = false
        mainView.enableControlButtonsForCall(enabled: true)
        mainView.connectCallHolder(connected: multipartyCommunicator.isCallEnabled)
        mainView.addPublisherView(multipartyCommunicator.publisherView)
        
    case .subscriberReady:  // one participant joins
        SVProgressHUD.popActivity()
        if let remote = remote, subscribers.index(of: remote) == nil {
            subscribers.append(remote)
            mainView.updateSubscriberViews(subscribers, publisherView: multipartyCommunicator?.publisherView)
        }
        
    case .subscriberDestroyed:  // one participant leaves
        if let remote = remote, let index = subscribers.index(of: remote) {
            subscribers.remove(at: index)
            mainView.updateSubscriberViews(subscribers, publisherView: multipartyCommunicator?.publisherView)
        }
        ...
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

The textchat logic and UI is pre-configured, you can also change properties like `textChatNavigationBar.topItem.title` and `alias` in `TextChatTableViewController`:

```objc
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
``` 

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    
    textChat = OTTextChat()
    textChat?.dataSource = self
    textChat?.alias = "Toxboxer"
    
    textChatNavigationBar.topItem?.title = textChat?.alias
    tableView.textChatTableViewDelegate = self
    tableView.separatorStyle = .none
    textChatInputView.textField.delegate = self
    
    textChat?.connect(handler: { (signal, connection, error) in
        
        guard error == nil else {
            SVProgressHUD.showError(withStatus: error!.localizedDescription)
            return
        }
        
        if signal == .didConnect {
            print("Text Chat starts")
        }
        else if signal == .didDisconnect {
            print("Text Chat stops")
        }
        
    }) { [unowned self](signal, message, error) in
        
        guard error == nil, let message = message else {
            SVProgressHUD.showError(withStatus: error!.localizedDescription)
            return
        }
        
        self.textMessages.append(message)
        self.tableView.reloadData()
        self.textChatInputView.textField.text = nil
        self.scrollTextChatTableViewToBottom()
    }
    
    textChatInputView.sendButton.addTarget(self, action: #selector(TextChatTableViewController.sendTextMessage), for: .touchUpInside)
}
```

###ScreenShare

The **screen share** features shares images from your camera roll using the `ScreenShareViewController` class which publishes the content.

```objc
- (void)startScreenSharing {
    self.multipartyScreenSharer = [[OTMultiPartyCommunicator alloc] initWithView:self.annotationView];
    self.multipartyScreenSharer.dataSource = self;
    
    // publishOnly here is to avoid subscripting to those who already subscribed
    self.multipartyScreenSharer.publishOnly = YES;
    
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

```swift
fileprivate func startScreenSharing() {
    multipartyScreenSharer = OTMultiPartyCommunicator.init(view: annotationView)
    multipartyScreenSharer?.dataSource = self
    
    // publishOnly here is to avoid subscripting to those who already subscribed
    multipartyScreenSharer?.isPublishOnly = true
    
    multipartyScreenSharer?.connect {
        [unowned self](signal, remote, error) in
        
        guard error == nil else {
            self.dismiss(animated: true) {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            }
            return
        }
        
        if signal == .publisherCreated {
            self.multipartyScreenSharer?.isPublishAudio = false
            self.startAnnotation()
        }
    }
}
```
   
###Annotation

The `ScreenShareViewController` class also handles local annotation:

The beta version is unstable when it comes to work with cross-platform, it's much stable if two canvas has same aspect ratio. For more information, please contact us.

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

```swift
fileprivate func startAnnotation() {
    annotator = OTAnnotator()
    annotator?.dataSource = self
    annotator?.connect {
        [unowned self] (signal, error) in
        
        guard error == nil else {
            self.dismiss(animated: true) {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            }
            return
        }
        
        if signal == .sessionDidConnect {
            
            guard let annotator = self.annotator,
                    let toolbarView = annotator.annotationScrollView.toolbarView else {
                print("Error on launching annotation")
                return
            }
            
            // using frame and self.view to contain toolbarView is for having more space to interact with color picker
            self.annotator?.annotationScrollView.initializeToolbarView()
            toolbarView.toolbarViewDataSource = self
            toolbarView.frame = self.annotationToolbarView.frame
            self.view.addSubview(toolbarView)

            annotator.annotationScrollView.frame = self.annotationView.bounds;
            annotator.annotationScrollView.scrollView.contentSize = CGSize(width: CGFloat(annotator.annotationScrollView.bounds.width), height: CGFloat(annotator.annotationScrollView.bounds.height))
            self.annotationView.addSubview(annotator.annotationScrollView)
            
            annotator.annotationScrollView.isAnnotatable = false
        }
    }
}
```

## Development and Contributing

Interested in contributing? We :heart: pull requests! See the [Contribution](CONTRIBUTING.md) guidelines.

## Getting Help

We love to hear from you so if you have questions, comments or find a bug in the project, let us know! You can either:

- Open an issue on this repository
- See <https://support.tokbox.com/> for support options
- Tweet at us! We're [@VonageDev](https://twitter.com/VonageDev) on Twitter
- Or [join the Vonage Developer Community Slack](https://developer.nexmo.com/community/slack)

## Further Reading

- Check out the Developer Documentation at <https://tokbox.com/developer/>
  