//
//  UIColorChain.swift
//  MVVM
//
//  Created by 张坤 on 2019/5/16.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import UIKit

extension UIColor: NamespaceWrappable { }
extension NamespaceWrapper where T: UIColor {
    /// 0xFFDF45
    static var theme: UIColor { return UIColor(hex: 0xFFDF45) }
    /// 0xD8D8D8
    static var lightGray: UIColor { return UIColor(hex: 0xD8D8D8) }
    /// 0xEFEFEF
    static var shadow: UIColor { return UIColor(hex: 0x000000).withAlphaComponent(0.1) }
}
