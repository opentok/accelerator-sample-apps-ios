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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        session = OTAcceleratorSession(openTokApiKey: <#T##String!#>, sessionId: <#T##String!#>, token: <#T##String!#>)
        return true
    }
}

