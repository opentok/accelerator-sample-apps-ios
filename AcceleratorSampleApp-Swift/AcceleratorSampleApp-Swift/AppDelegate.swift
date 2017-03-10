//
//  AppDelegate.swift
//
//  Copyright © 2017 Tokbox, Inc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private(set) var session: OTAcceleratorSession?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        session = OTAcceleratorSession.init(openTokApiKey: "100", sessionId: "1_MX4xMDB-fjE0ODkxMjUwMTYwMDd-QkJLL2doRUtkS29pY1lrL0tad2FuSjNPfn4", token: "T1==cGFydG5lcl9pZD0xMDAmc2RrX3ZlcnNpb249dGJwaHAtdjAuOTEuMjAxMS0wNy0wNSZzaWc9YTQ3ZDg5YzZiZmQ4YTc2YjhhMGVhY2ZkMzJlNzcxYWI1ZDg4YTUxZTpzZXNzaW9uX2lkPTFfTVg0eE1EQi1makUwT0RreE1qVXdNVFl3TURkLVFrSkxMMmRvUlV0a1MyOXBZMWxyTDB0YWQyRnVTak5QZm40JmNyZWF0ZV90aW1lPTE0ODkxMjUwMTYmcm9sZT1tb2RlcmF0b3Imbm9uY2U9MTQ4OTEyNTAxNi4zMTg0Njc0NDk2MjQ0JmV4cGlyZV90aW1lPTE0OTE3MTcwMTY=")
        return true
    }
}

