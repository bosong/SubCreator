//
//  GalleryViewController.swift
//  SubCreator
//
//  Created by ripple_k on 2019/9/23.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import Foundation
import Fusuma

class GalleryViewControler: HomepageViewController {
    // MARK: - Properties
    // MARK: - Initialized
    // MARK: - UI properties
    // MARK: - View Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        uploadButton.isHidden = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: HomePageTitleView("创作"))
    }
    
    // MARK: - SEL
    @objc func showPhoto() {
        let fusuma = FusumaViewController().then { (fusuma) in
            fusuma.delegate = self
            fusuma.availableModes = [FusumaMode.library, FusumaMode.camera]
            fusuma.cropHeightRatio = Metric.ItemRatio
            fusuma.allowMultipleSelection = false
            fusumaCameraRollTitle = "相册"
            fusumaCameraTitle = "拍照"
        }
        self.present(fusuma, animated: true, completion: nil)
    }
    
    // MARK: - Private Functions
    
}
