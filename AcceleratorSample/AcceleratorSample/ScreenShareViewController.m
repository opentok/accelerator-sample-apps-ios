//
//  ScreenShareViewController.m
//  AcceleratorSampleApp
//
//  Created by Xi Huang on 3/8/17.
//  Copyright © 2017 Tokbox, Inc. All rights reserved.
//

#import "ScreenShareViewController.h"

#import "AppDelegate.h"

#import "OTAnnotator.h"
#import "OTMultiPartyCommunicator.h"

#import <SVProgressHUD/SVProgressHUD.h>

@interface ScreenShareViewController () <OTMultiPartyCommunicatorDataSource, OTAnnotatorDataSource, OTAnnotationToolbarViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *extiButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *annotationView;
@property (weak, nonatomic) IBOutlet UIView *annotationToolbarView;

@property (nonatomic) OTMultiPartyCommunicator *multipartyScreenSharer;
@property (nonatomic) OTAnnotator *annotator;
@end

@implementation ScreenShareViewController

- (void)setSharingImage:(UIImage *)sharingImage {
    _sharingImage = sharingImage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self styleUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.imageView.image = _sharingImage;
    [self startScreenSharing];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (self.annotator) {
        self.annotator.annotationScrollView.frame = self.annotationView.bounds;
        self.annotator.annotationScrollView.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.annotator.annotationScrollView.bounds), CGRectGetHeight(self.annotator.annotationScrollView.bounds));
    }
    
    if (self.annotator.annotationScrollView.toolbarView) {
        self.annotator.annotationScrollView.toolbarView.frame = self.annotationToolbarView.frame;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.multipartyScreenSharer disconnect];
    self.multipartyScreenSharer = nil;
    [self.annotator.annotationScrollView removeFromSuperview];
    [self.annotator.annotationScrollView.annotationView removeFromSuperview];
    [self.annotator disconnect];
    self.annotator = nil;
}

- (void)styleUI {
    self.extiButton.layer.cornerRadius = CGRectGetWidth(self.extiButton.bounds) / 2;
}

- (void)startScreenSharing {
    self.multipartyScreenSharer = [[OTMultiPartyCommunicator alloc] initWithView:self.annotationView];
    self.multipartyScreenSharer.publishOnly = YES;
    self.multipartyScreenSharer.dataSource = self;
    __weak ScreenShareViewController *weakSelf = self;
    [self.multipartyScreenSharer connectWithHandler:^(OTCommunicationSignal signal, OTMultiPartyRemote *subscriber, NSError *error) {
        
        if (error) {
            [self dismissViewControllerAnimated:YES completion:^(){
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }];
            return;
        }
        
        if (signal == OTPublisherCreated) {
            [weakSelf startAnnotation];
        }
    }];
}

- (void)startAnnotation {
    self.multipartyScreenSharer.publishAudio = NO;
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

- (IBAction)exitButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (OTAcceleratorSession *)sessionOfOTAnnotator:(OTAnnotator *)annotator {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return appDelegate.acceleratorSession;
}

- (OTAcceleratorSession *)sessionOfOTMultiPartyCommunicator:(OTMultiPartyCommunicator *)multiPartyCommunicator {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return appDelegate.acceleratorSession;
}

- (UIView *)annotationToolbarViewForRootViewForScreenShot:(OTAnnotationToolbarView *)toolbarView {
    return self.annotationView;
}

@end
