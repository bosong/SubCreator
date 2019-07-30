//
//  AppDelegate.swift
//  SubCreator
//
//  Created by rpple_k on 2019/7/30.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var dependency: AppDependency!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        dependency = dependency ?? CompositionRoot.resolve()
        dependency.configureSDKs()
        dependency.configureAppearance()
        dependency.configurePreferences()
        return true
    }
}
