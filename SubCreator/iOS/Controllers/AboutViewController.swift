//
//  AboutViewController.swift
//  SubCreator
//
//  Created by ripple_k on 2019/11/6.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import UIKit

class AboutViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "关于我们"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adjustLeftBarButtonItem()
    }
}
