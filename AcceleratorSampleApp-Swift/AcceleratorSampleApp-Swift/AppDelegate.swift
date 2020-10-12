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
        session = OTAcceleratorSession.init(openTokApiKey: "46934974", sessionId: "1_MX40NjkzNDk3NH5-MTYwMjQ5OTIzMTEwMH54QWFXVUdXTUIzWU53ODdrRmQ1RVVTQkx-fg", token: "T1==cGFydG5lcl9pZD00NjkzNDk3NCZzaWc9YjhlZDZjZmZlNmExOTQ3Y2QwMjRmNmE3YzBmNGFmMGU5NjQ5ZmY3NjpzZXNzaW9uX2lkPTFfTVg0ME5qa3pORGszTkg1LU1UWXdNalE1T1RJek1URXdNSDU0UVdGWFZVZFhUVUl6V1U1M09EZHJSbVExUlZWVFFreC1mZyZjcmVhdGVfdGltZT0xNjAyNDk5MjQxJm5vbmNlPTAuMjcyODczMjE5NDc0NTM5MzUmcm9sZT1wdWJsaXNoZXImZXhwaXJlX3RpbWU9MTYwMjU4NTY0MCZpbml0aWFsX2xheW91dF9jbGFzc19saXN0PQ==")
        return true
    }
}

