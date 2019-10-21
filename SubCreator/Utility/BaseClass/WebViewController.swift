//
//  WebViewController.swift
//  ABTest
//
//  Created by ripple_k on 2018/11/10.
//  Copyright © 2018 mtVideo. All rights reserved.
//

import UIKit

open class WebViewController: UIViewController {
    
    public let webView = UIWebView()

    override open func viewDidLoad() {
        super.viewDidLoad()
        webView
            .mt.adhere(toSuperView: self.view)
            .mt.layout { (make) in
                make.edges.equalToSuperview()
        }
        webView.backgroundColor = UIColor.white
        view.backgroundColor = UIColor.white
        self.navigationItem.leftBarButtonItem =
            UIBarButtonItem(title: "返回",
                            style: .done,
                            target: self,
                            action: #selector(p_dismiss))
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar
            .setBackgroundImage(UIImage.resizable().color(UIColor.white).image, for: .default)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        self.navigationController?.navigationBar.barStyle = .black
    }
    
    @objc private func p_dismiss() {
        self.dismiss(animated: true, completion: nil)
    }

}
