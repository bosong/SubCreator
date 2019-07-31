//
//  CALayer+Ex.swift
//  BGIMAdmin
//
//  Created by rpple_k on 2019/7/19.
//  Copyright © 2019 sks. All rights reserved.
//

import UIKit

extension CALayer {
    // swiftlint:disable identifier_name
    func applySketchShadow(
        color: UIColor = .black,
        alpha: Float = 0.5,
        x: CGFloat = 0,
        y: CGFloat = 2,
        blur: CGFloat = 4,
        spread: CGFloat = 0) {
            shadowColor = color.cgColor
            shadowOpacity = alpha
            shadowOffset = CGSize(width: x, height: y)
            shadowRadius = blur / 2.0
            if spread == 0 {
                shadowPath = nil
            } else {
                let dx = -spread
                let rect = bounds.insetBy(dx: dx, dy: dx)
                shadowPath = UIBezierPath(rect: rect).cgPath
            }
    }
}
