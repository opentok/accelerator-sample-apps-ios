//
//  MainView.h
//
// Copyright © 2016 Tokbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTMultiPartyCommunicator.h"

@interface MainView : UIView

@property (readonly, weak, nonatomic) UIButton *screenShareButton;

// publisher view
- (void)addPublisherView:(UIView *)publisherView;
- (void)updateSubscriberViews:(NSArray<OTMultiPartyRemote *> *)subscriberViews
                publisherView:(UIView *)publisherView;

- (void)connectCallHolder:(BOOL)connected;
- (void)updatePublisherAudio:(BOOL)connected;
- (void)updatePublisherVideo:(BOOL)connected;

- (void)enableControlButtonsForCall:(BOOL)enabled;

- (void)resetAllControl;

@end
