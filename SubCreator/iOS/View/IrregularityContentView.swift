//
//  IrregularityContentView.swift
//  SubCreator
//
//  Created by ripple_k on 2019/9/17.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import ESTabBarController_swift

class IrregularityContentView: ESTabBarItemContentView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        self.imageView.backgroundColor = UIColor.init(red: 23/255.0, green: 149/255.0, blue: 158/255.0, alpha: 1.0)
//        self.imageView.layer.borderWidth = 3.0
//        self.imageView.layer.borderColor = UIColor.init(white: 235 / 255.0, alpha: 1.0).cgColor
//        self.imageView.layer.cornerRadius = 35
        self.insets = UIEdgeInsets.init(top: -32, left: 0, bottom: 0, right: 0)
//        let transform = CGAffineTransform.identity
//        self.imageView.transform = transform
        self.tintColor = .clear
        self.superview?.bringSubviewToFront(self)
        
//        textColor = UIColor.init(white: 255.0 / 255.0, alpha: 1.0)
//        highlightTextColor = UIColor.init(white: 255.0 / 255.0, alpha: 1.0)
//        iconColor = UIColor.init(white: 255.0 / 255.0, alpha: 1.0)
//        highlightIconColor = UIColor.init(white: 255.0 / 255.0, alpha: 1.0)
//        backdropColor = .clear
//        highlightBackdropColor = .clear
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let p = CGPoint.init(x: point.x - imageView.frame.origin.x, y: point.y - imageView.frame.origin.y)
        return sqrt(pow(imageView.bounds.size.width / 2.0 - p.x, 2) + pow(imageView.bounds.size.height / 2.0 - p.y, 2)) < imageView.bounds.size.width / 2.0
    }
    
    override func updateLayout() {
        super.updateLayout()
        self.imageView.sizeToFit()
        self.imageView.center = CGPoint.init(x: self.bounds.size.width / 2.0, y: self.bounds.size.height / 2.0)
    }
}
