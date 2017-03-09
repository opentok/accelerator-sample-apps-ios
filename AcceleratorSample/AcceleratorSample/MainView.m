//
//  MainView.m
//
// Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import "MainView.h"
#import "UIView+Helper.h"

@interface MainView()

// 3 action buttons at the bottom of the view
@property (weak, nonatomic) IBOutlet UIButton *publisherVideoButton;
@property (weak, nonatomic) IBOutlet UIButton *publisherAudioButton;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) IBOutlet UIButton *screenShareButton;
@property (weak, nonatomic) IBOutlet UIView *holderView;
@end

@implementation MainView

- (void)awakeFromNib {
    [super awakeFromNib];

    self.publisherAudioButton.enabled = YES;
    self.publisherVideoButton.enabled = YES;
    self.messageButton.enabled = YES;
    self.screenShareButton.enabled = YES;
    
    [self drawBorderOn:self.publisherAudioButton withWhiteBorder:YES];
    [self drawBorderOn:self.publisherVideoButton withWhiteBorder:YES];
    [self drawBorderOn:self.messageButton withWhiteBorder:YES];
    [self drawBorderOn:self.screenShareButton withWhiteBorder:YES];
}

- (void)drawBorderOn:(UIView *)view
     withWhiteBorder:(BOOL)withWhiteBorder {
    
    view.layer.cornerRadius = (view.bounds.size.width / 2);
    if (withWhiteBorder) {
        view.layer.borderWidth = 1;
        view.layer.borderColor = [UIColor whiteColor].CGColor;
    }
}

#pragma mark - publisher view
- (void)addPublisherView:(UIView *)publisherView {
    publisherView.layer.backgroundColor = [UIColor grayColor].CGColor;
    publisherView.frame = self.frame;
    [self.holderView addSubview:publisherView];
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
        [self.holderView addSubview:remote.subscriberView];
        
        // update x and y value
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

@end
