//
//  MainViewController.m
//
// Copyright © 2017 Tokbox, Inc. All rights reserved.
//

#import "MainView.h"
#import "MainViewController.h"
#import "ScreenShareViewController.h"
#import "OTMultiPartyCommunicator.h"
#import "AppDelegate.h"

#import "TextChatTableViewController.h"

#import <SVProgressHUD/SVProgressHUD.h>

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
    }
    else {
        
        // end call
        [SVProgressHUD dismiss];
        [self.multipartyCommunicator disconnect];
        [self.mainView resetAllControl];
        [self.subscribers removeAllObjects];
    }
}

- (void)handleCommunicationSignal:(OTCommunicationSignal)signal
                           remote:(OTMultiPartyRemote *)remote {
    
    switch (signal) {
        case OTPublisherCreated: {  // join a call
            [SVProgressHUD dismiss];
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
            [SVProgressHUD dismiss];
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
        case OTSessionDidBeginReconnecting: {
            [SVProgressHUD showInfoWithStatus:@"Reconnecting"];
            break;
        }
        case OTSessionDidReconnect: {
            [SVProgressHUD dismiss];
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
        // handle iPhone
        [self presentViewController:self.screenShareMenuAlertController animated:YES completion:nil];
    }
    else {
        // handle iPad
        self.screenShareMenuAlertController.modalPresentationStyle = UIModalPresentationPopover;
        self.screenShareMenuAlertController.popoverPresentationController.sourceView = self.mainView.screenShareButton;
        self.screenShareMenuAlertController.popoverPresentationController.sourceRect = self.mainView.screenShareButton.bounds;
        [self presentViewController:self.screenShareMenuAlertController animated:YES completion:nil];
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
