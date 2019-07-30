//
//  CompositionRoot.swift
//  SubCreator
//
//  Created by rpple_k on 2019/7/30.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import UIKit

public struct AppDependency {
    public let window: UIWindow
    public let configureSDKs: () -> Void
    public let configureAppearance: () -> Void
    public let configurePreferences: () -> Void
}

public final class CompositionRoot {
    /// Builds a dependency graph and returns an entry view controller.
    public static func resolve() -> AppDependency {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = .white
        let homepageVC = HomepageViewController()
        homepageVC.reactor = HomepageViewReactor()
        window.rootViewController = UINavigationController(rootViewController: homepageVC)
        window.makeKeyAndVisible()
        
        return AppDependency(window: window,
                             configureSDKs: self.configureSDKs,
                             configureAppearance: self.configureAppearance,
                             configurePreferences: self.configurePreferences
        )
    }
    
    /// ConfigureSDKs for App
    static func configureSDKs() {
        
    }
    
    /// ConfigureAppearance for App
    static func configureAppearance() {
        UINavigationBar.appearance().tintColor = .black
        UINavigationBar.appearance().shadowImage = UIImage.resizable().color(.white).image
        UINavigationBar.appearance().backgroundColor = UIColor.white
    }
    
    /// ConfigurePreferences for App
    static func configurePreferences() {
        
    }
}
