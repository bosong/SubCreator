//
//  HomePageCollectionViewCell.swift
//  SubCreator
//
//  Created by rpple_k on 2019/7/30.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import UIKit

class HomePageCollectionViewCell: BaseCollectionViewCell {
    let imgV = UIImageView()
    
    override func setupSubviews() {
        imgV
            .mt.adhere(toSuperView: contentView)
            .mt.config({ (imgV) in
                imgV.layer.cornerRadius = 6
                imgV.clipsToBounds = true
            })
            .mt.layout { (make) in
                make.edges.equalToSuperview()
        }
    }
}
