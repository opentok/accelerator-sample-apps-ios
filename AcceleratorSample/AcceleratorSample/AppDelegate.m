//
//  AppDelegate.m
//
//  Copyright © 2017 Tokbox, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "OTAcceleratorSession.h"

@interface AppDelegate ()
@property (nonatomic, strong) OTAcceleratorSession* acceleratorSession;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.acceleratorSession = [[OTAcceleratorSession alloc] initWithOpenTokApiKey:<#apikey#>
                                                                        sessionId:<#sessionid#>
                                                                            token:<#token#>];
    return YES;
}

@end
