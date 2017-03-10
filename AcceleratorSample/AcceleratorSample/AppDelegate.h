//
//  AppDelegate.h
//
//  Copyright © 2017 Tokbox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OTAcceleratorSession;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong, readonly) OTAcceleratorSession* acceleratorSession;

@end

