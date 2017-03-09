//
//  AppDelegate.m
//  AcceleratorSample
//
//  Created by Xi Huang on 3/3/17.
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
    self.acceleratorSession = [[OTAcceleratorSession alloc] initWithOpenTokApiKey:@"100"
                                                                        sessionId:@"1_MX4xMDB-fjE0ODkwMTIyMzE3MDh-bnNwSklobUlxWDhSUGdWZmgrZmdsQy82fn4"
                                                                            token:@"T1==cGFydG5lcl9pZD0xMDAmc2RrX3ZlcnNpb249dGJwaHAtdjAuOTEuMjAxMS0wNy0wNSZzaWc9NTQyMWE3MGJlOTJjZDg2ZTI4NjEzYzQ5NzgxZjFkMTMyM2Y3MWZjNzpzZXNzaW9uX2lkPTFfTVg0eE1EQi1makUwT0Rrd01USXlNekUzTURoLWJuTndTa2xvYlVseFdEaFNVR2RXWm1nclptZHNReTgyZm40JmNyZWF0ZV90aW1lPTE0ODkwMTIyMzEmcm9sZT1tb2RlcmF0b3Imbm9uY2U9MTQ4OTAxMjIzMS44MDQ4ODUzNTg5OTcyJmV4cGlyZV90aW1lPTE0OTE2MDQyMzE="];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
