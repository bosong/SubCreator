//
//  HomePageCollectionViewCell.swift
//  SubCreator
//
//  Created by ripple_k on 2019/7/30.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import UIKit
import Hero

class HomePageCollectionViewCell: BaseCollectionViewCell {
    let imgV = UIImageView()
    private let selImgV = UIImageView(image: R.image.icon_sel())
    var isSel = false {
        didSet {
            selImgV.isHidden = !self.isSel
        }
    }
    
    override func setupSubviews() {
        self.layer.applySketchShadow(color: UIColor.black, alpha: 0.5, x: 0, y: 2, blur: 4, spread: 0)
        imgV
            .mt.adhere(toSuperView: contentView)
            .mt.config({ (imgV) in
                imgV.layer.cornerRadius = 6
                imgV.clipsToBounds = true
                imgV.contentMode = .scaleAspectFill
            })
            .mt.layout { (make) in
                make.edges.equalToSuperview()
        }
        selImgV
            .mt.config({ (imgV) in
                imgV.isHidden = true
            })
            .mt.adhere(toSuperView: contentView)
            .mt.layout { (make) in
                make.right.equalTo(-10)
                make.top.equalTo(10)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.hero.id = nil
        self.selImgV.isHidden = true
        isSel = false
    }
}
