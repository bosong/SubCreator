//
//  BaseNavigationViewController.swift
//  SubCreator
//
//  Created by ripple_k on 2019/9/20.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import UIKit

class BaseNavigationViewController: UINavigationController {
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    deinit {
        log.verbose("SoapNavigationController deinit")
    }
    
    override open func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: true)
    }
    
    open override var shouldAutorotate: Bool {
        return self.topViewController?.shouldAutorotate ?? false
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.topViewController?
            .supportedInterfaceOrientations ??
            .portrait
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return self.topViewController?
            .preferredInterfaceOrientationForPresentation ??
            .portrait
    }
}
