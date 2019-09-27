//
//  CompositionRoot.swift
//  SubCreator
//
//  Created by rpple_k on 2019/7/30.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import UIKit
import ESTabBarController_swift
import Fusuma

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
        
//        let homepageVC = HomepageViewController(reactor: HomepageViewReactor())
        window.rootViewController = TabBarController()
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
        UINavigationBar.appearance().shadowImage = UIImage.resizable().color(UIColor.white).image
        UINavigationBar.appearance().backgroundColor = .white
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance()
            .setBackgroundImage(UIImage.resizable().color(UIColor.white).image, for: .default)
    }
    
    /// ConfigurePreferences for App
    static func configurePreferences() {
        
    }
}
