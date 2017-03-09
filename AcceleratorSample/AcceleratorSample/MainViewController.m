//
//  MainViewController.m
//
// Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "MainView.h"
#import "MainViewController.h"
#import "ScreenShareViewController.h"
#import "OTMultiPartyCommunicator.h"
#import "AppDelegate.h"

#import "TextChatTableViewController.h"

#import <SVProgressHUD/SVProgressHUD.h>

#define MAKE_WEAK(self) __weak typeof(self) weak##self = self
#define MAKE_STRONG(self) __strong typeof(weak##self) strong##self = weak##self

@interface MainViewController () <OTMultiPartyCommunicatorDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    UIImage *selectedImage;
}
@property (nonatomic) MainView *mainView;
@property (nonatomic) OTMultiPartyCommunicator *multipartyCommunicator;
@property (nonatomic) NSMutableArray *subscribers;

@property (nonatomic) UIAlertController *screenShareMenuAlertController;
@property (nonatomic) UIImagePickerController *imagePickerViewContoller;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mainView = (MainView *)self.view;
    
    self.multipartyCommunicator = [[OTMultiPartyCommunicator alloc] init];
    self.multipartyCommunicator.dataSource = self;
    self.subscribers = [[NSMutableArray alloc] initWithCapacity:6];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.mainView updateSubscriberViews:self.subscribers
                           publisherView:self.multipartyCommunicator.publisherView];
}

- (IBAction)publisherCallButtonPressed:(UIButton *)sender {
    
    if (!self.multipartyCommunicator.isCallEnabled) {
        [SVProgressHUD show];

        MAKE_WEAK(self);
        [self.multipartyCommunicator connectWithHandler:^(OTCommunicationSignal signal, OTMultiPartyRemote *subscriber, NSError *error) {
            MAKE_STRONG(self);
            strongself.multipartyCommunicator.publisherView.showAudioVideoControl = NO;
            if (!error) {
                [strongself handleCommunicationSignal:signal remote:subscriber];
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

- (void)handleCommunicationSignal:(OTCommunicationSignal)signal
                           remote:(OTMultiPartyRemote *)remote {
    
    switch (signal) {
        case OTPublisherCreated: {
            [SVProgressHUD popActivity];
            [self.mainView enableControlButtonsForCall:YES];
            [self.mainView connectCallHolder:self.multipartyCommunicator.isCallEnabled];
            [self.mainView addPublisherView:self.multipartyCommunicator.publisherView];
            break;
        }
        case OTPublisherDestroyed: {
            NSLog(@"Your publishing feed stops streaming in OpenTok");
            break;
        }
        case OTSubscriberCreated: {
            [SVProgressHUD show];
        }
        case OTSubscriberReady: {
            [SVProgressHUD popActivity];
            if (![self.subscribers containsObject:remote]) {
                [self.subscribers addObject:remote];
                [self.mainView updateSubscriberViews:self.subscribers
                                       publisherView:self.multipartyCommunicator.publisherView];
            }
            break;
        }
        case OTSubscriberDestroyed:{
            if ([self.subscribers containsObject:remote]) {
                [self.subscribers removeObject:remote];
                [self.mainView updateSubscriberViews:self.subscribers
                                       publisherView:self.multipartyCommunicator.publisherView];
            }
            break;
        }
        case OTSessionDidBeginReconnecting: {
            [SVProgressHUD showInfoWithStatus:@"Reconnecting"];
            break;
        }
        case OTSessionDidReconnect: {
            [SVProgressHUD popActivity];
            break;
        }
//        case OTSubscriberVideoDisabledByBadQuality:
//        case OTSubscriberVideoDisabledBySubscriber:
//        case OTSubscriberVideoDisabledByPublisher:{
//            self.oneToOneCommunicator.subscribeToVideo = NO;
//            break;
//        }
//        case OTSubscriberVideoEnabledByGoodQuality:
//        case OTSubscriberVideoEnabledBySubscriber:
//        case OTSubscriberVideoEnabledByPublisher:{
//            self.oneToOneCommunicator.subscribeToVideo = YES;
//            break;
//        }
//        case OTSubscriberVideoDisableWarning:{
//            self.oneToOneCommunicator.subscribeToVideo = NO;
//            [SVProgressHUD showErrorWithStatus:@"Network connection is unstable."];
//            break;
//        }
//        case OTSubscriberVideoDisableWarningLifted:{
//            self.oneToOneCommunicator.subscribeToVideo = YES;
//            break;
//        }
        default: break;
    }
}

- (IBAction)publisherAudioButtonPressed:(UIButton *)sender {
    self.multipartyCommunicator.publishAudio = !self.multipartyCommunicator.publishAudio;
    [self.mainView updatePublisherAudio:self.multipartyCommunicator.publishAudio];
}

- (IBAction)publisherVideoButtonPressed:(UIButton *)sender {
    self.multipartyCommunicator.publishVideo = !self.multipartyCommunicator.publishVideo;
    [self.mainView updatePublisherVideo:self.multipartyCommunicator.publishVideo];
}

- (IBAction)textMessageButtonPressed:(id)sender {
    [self presentViewController:[[TextChatTableViewController alloc] init] animated:YES completion:nil];
}

- (IBAction)screenShareButtonPressed:(id)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:self.screenShareMenuAlertController animated:YES completion:nil];
    }
    else {
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:self.screenShareMenuAlertController];
        [popup presentPopoverFromRect:self.mainView.screenShareButton.bounds
                               inView:self.mainView.screenShareButton
             permittedArrowDirections:UIPopoverArrowDirectionAny
                             animated:YES];
    }
}

- (OTAcceleratorSession *)sessionOfOTMultiPartyCommunicator:(OTMultiPartyCommunicator *)multiPartyCommunicator {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return appDelegate.acceleratorSession;
}

#pragma mark - UIImagePickerControllerDelegate, UINavigationControllerDelegate
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[ScreenShareViewController class]]) {

        ScreenShareViewController *vc = (ScreenShareViewController *)segue.destinationViewController;
        vc.sharingImage = selectedImage;
    }
}

- (UIAlertController *)screenShareMenuAlertController {
    if (!_screenShareMenuAlertController) {
        _screenShareMenuAlertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:@"Please choose the content you want to share"
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
        
        
        __weak MainViewController *weakSelf = self;
        UIAlertAction *cameraRollAction = [UIAlertAction actionWithTitle:@"Camera Roll"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction *action) {
                                                                     
                                                                     if (!_imagePickerViewContoller) {
                                                                         _imagePickerViewContoller = [[UIImagePickerController alloc] init];
                                                                         _imagePickerViewContoller.delegate = weakSelf;
                                                                         _imagePickerViewContoller.allowsEditing = YES;
                                                                         _imagePickerViewContoller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                                     }
                                                                     [weakSelf presentViewController:_imagePickerViewContoller animated:YES completion:nil];
                                                                 }];
        
        [_screenShareMenuAlertController addAction:cameraRollAction];
        [_screenShareMenuAlertController addAction:
         [UIAlertAction actionWithTitle:@"Cancel"
                                  style:UIAlertActionStyleDestructive
                                handler:^(UIAlertAction *action) {
                                    
                                    [_screenShareMenuAlertController dismissViewControllerAnimated:YES completion:nil];
                                }]
         ];
    }
    return _screenShareMenuAlertController;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    selectedImage = info[UIImagePickerControllerOriginalImage];
    __weak MainViewController *weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^(){
        [weakSelf performSegueWithIdentifier:@"ScreenSharing" sender:nil];
    }];
}

@end
