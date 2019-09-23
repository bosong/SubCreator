//
//  BaseNavigationViewController.swift
//  SubCreator
//
//  Created by ripple_k on 2019/9/20.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import UIKit

class BaseNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.tintColor = .black
        navigationBar.shadowImage = UIImage.resizable().color(.white).image
        navigationBar.backgroundColor = UIColor.white
    }
}
