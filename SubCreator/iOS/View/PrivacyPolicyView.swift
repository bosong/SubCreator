//
//  PrivacyPolicyView.swift
//  ABTest
//
//  Created by ripple_k on 2018/11/10.
//  Copyright © 2018 SoapVideo. All rights reserved.
//

import UIKit

class PrivacyPolicyView: UIView {
    static func show(in controller: UIViewController, privacyPolicyClosure: @escaping (Bool) -> Void) {
        guard let privacyView = UINib(nibName: "PrivacyPolicyView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? PrivacyPolicyView else { return }
        privacyView.privacyPolicyClosure = privacyPolicyClosure
        let alertVC = KAlertController(alertView: privacyView, preferredStyle: .alert)
        privacyView.dismissClosure = {
            alertVC.dismiss(animated: true, completion: nil)
        }
        
        controller.present(alertVC, animated: true, completion: nil)
    }

    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var disAgreeButton: UIButton!
    @IBOutlet weak var privacyPolicyButton: UIButton!
    
    var privacyPolicyClosure: ((Bool) -> Void)?
    var dismissClosure: (() -> Void)?
    
    @IBAction func agree() {
        privacyPolicyClosure?(true)
        dismissClosure?()
    }
    
    @IBAction func disAgree() {
        privacyPolicyClosure?(false)
        dismissClosure?()
    }
    
    @IBAction func privacyPolicy() {
        if let path = Bundle.main.path(forResource: "privacy", ofType: "html") {
            let webVC = WebViewController()
            let url = URL(fileURLWithPath: path)
            let request = URLRequest(url: url)
            webVC.webView.loadRequest(request)
            webVC.title = "“搞笑字幕”隐私政策"
            findViewController(view: self)
                .present(BaseNavigationViewController(rootViewController: webVC), animated: true, completion: nil)
        }
    }
    
    @IBAction func eulaPolicy() {
        if let path = Bundle.main.path(forResource: "EULA", ofType: "html") {
            let webVC = WebViewController()
            let url = URL(fileURLWithPath: path)
            let request = URLRequest(url: url)
            webVC.webView.loadRequest(request)
            findViewController(view: self)
                .present(BaseNavigationViewController(rootViewController: webVC), animated: true, completion: nil)
        }
    }
}
