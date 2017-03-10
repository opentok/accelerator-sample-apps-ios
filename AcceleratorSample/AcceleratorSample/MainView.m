//
//  MainView.m
//
// Copyright © 2017 Tokbox, Inc. All rights reserved.
//

#import "MainView.h"

@interface ControlButton: UIButton

@end

@implementation ControlButton

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.layer.cornerRadius = self.bounds.size.width / 2;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
}

@end

@interface MainView()

// 3 action buttons at the bottom of the view
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet ControlButton *publisherVideoButton;
@property (weak, nonatomic) IBOutlet ControlButton *publisherAudioButton;
@property (weak, nonatomic) IBOutlet ControlButton *messageButton;
@property (weak, nonatomic) IBOutlet ControlButton *screenShareButton;
@property (weak, nonatomic) IBOutlet UIView *holderView;
@end

@implementation MainView

- (void)awakeFromNib {
    [super awakeFromNib];

    self.callButton.enabled = YES;
    self.callButton.layer.cornerRadius = self.callButton.bounds.size.width / 2;
}

#pragma mark - publisher view
- (void)addPublisherView:(UIView *)publisherView {
    publisherView.layer.backgroundColor = [UIColor grayColor].CGColor;
    publisherView.frame = self.frame;
    [self.holderView addSubview:publisherView];
}

- (void)connectCallHolder:(BOOL)connected {
    [self.callButton setImage:connected ? [UIImage imageNamed:@"hangUp"] : [UIImage imageNamed:@"startCall"]  forState:UIControlStateNormal];
    self.callButton.layer.backgroundColor = connected ? [UIColor colorWithRed:(205/255.0) green:(32/255.0) blue:(40/255.0) alpha:1.0].CGColor : [UIColor colorWithRed:(106/255.0) green:(173/255.0) blue:(191/255.0) alpha:1.0].CGColor;
}

- (void)updatePublisherAudio:(BOOL)connected {
    [self.publisherAudioButton setImage:connected ? [UIImage imageNamed:@"mic"] : [UIImage imageNamed:@"mutedMic"] forState:UIControlStateNormal];
}

- (void)updatePublisherVideo:(BOOL)connected {
    [self.publisherVideoButton setImage:connected ? [UIImage imageNamed:@"video"] : [UIImage imageNamed:@"noVideo"] forState:UIControlStateNormal];
}

- (void)updateSubscriberViews:(NSArray<OTMultiPartyRemote *> *)subscriberViews
                publisherView:(UIView *)publisherView {
    
    for (UIView *view in self.holderView.subviews) {
        [view removeFromSuperview];
    }
    
    if (subscriberViews.count == 0) {
        [self addPublisherView:publisherView];
        return;
    }
    
    if (subscriberViews.count == 1) {
        [self addPublisherView:publisherView];
        OTMultiPartyRemote *remote = [subscriberViews lastObject];
        remote.subscriberView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height / 2);
        [self.holderView addSubview:remote.subscriberView];
        return;
    }
    
    CGFloat height, subscriberWidth, publisherWidth;
    height = self.bounds.size.height / (subscriberViews.count / 2 + 1);
    subscriberWidth = subscriberViews.count + 1 > 2 ? self.bounds.size.width / 2 :  self.bounds.size.width;
    publisherWidth = (subscriberViews.count + 1) % 2 == 0 ? self.bounds.size.width / 2 : self.bounds.size.width;
    
    CGFloat x = 0, y = 0;
    for (int i = 0; i < subscriberViews.count; i++) {
        
        OTMultiPartyRemote *remote = subscriberViews[i];
        remote.subscriberView.frame = CGRectMake(x, y, subscriberWidth, height);
        
        // this will position and audio/video controls
        remote.subscriberView.controlView.backgroundColor = [UIColor blackColor];
        remote.subscriberView.controlView.isVerticalAlignment = YES;
        remote.subscriberView.controlView.frame = CGRectMake(10, 10, CGRectGetWidth(remote.subscriberView.bounds) * 0.2, CGRectGetHeight(remote.subscriberView.bounds) * 0.3);
        
        [self.holderView addSubview:remote.subscriberView];
        
        // update x and y value for the next subscriber view
        if ((i + 1) % 2 == 0) {
            x = 0;
        }
        else {
            x = subscriberWidth;
        }
        y = (i + 1) / 2 * height;
    }
    
    [self addPublisherView:publisherView];
    if (subscriberWidth != publisherWidth) {
        // publisher is at the bottom
        publisherView.frame = CGRectMake(0, y, publisherWidth, height);
    }
    else {
        // publisher is at the bottom right
        publisherView.frame = CGRectMake(self.bounds.size.width / 2, y, publisherWidth, height);
    }
    
}

#pragma mark - other controls
- (void)enableControlButtonsForCall:(BOOL)enabled {
    [self.publisherVideoButton setEnabled:enabled];
    [self.publisherAudioButton setEnabled:enabled];
    [self.messageButton setEnabled:enabled];
    [self.screenShareButton setEnabled:enabled];
}

- (void)resetAllControl {
    [self connectCallHolder:NO];
    [self updatePublisherAudio:YES];
    [self updatePublisherVideo:YES];
    [self enableControlButtonsForCall:NO];
}

@end
