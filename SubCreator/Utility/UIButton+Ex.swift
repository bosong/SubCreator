//
//  UIButton+Ex.swift
//  SubCreator
//
//  Created by ripple_k on 2019/9/27.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import UIKit

extension UIButton {
    // 放大按钮的点击区域
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let deltaW = max(44 - self.frame.width, 0)
        let deltaH = max(44 - self.frame.height, 0)
        let rect = self.bounds.insetBy(dx: -deltaW * 0.5, dy: -deltaH * 0.5)
        return rect.contains(point)
    }
}
