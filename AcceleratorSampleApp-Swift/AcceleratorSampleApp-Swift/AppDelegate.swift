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
        
        session = OTAcceleratorSession.init(openTokApiKey: <#apikey#>, sessionId: <#sessionid#>, token: <#token#>)
        return true
    }
}

