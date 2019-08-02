//
//  UIView+Extension.swift
//  DramaUIKit
//
//  Created by MorningStar on 2018/11/13.
//  Copyright © 2018 FeiZaoTai. All rights reserved.
//
//  swiftlint:disable identifier_name

import UIKit

public extension UIView {
    
    /// 裁剪 view 的圆角
    func clipRectCorner(direction: UIRectCorner, cornerRadius: CGFloat) {
        let cornerSize = CGSize(width: cornerRadius, height: cornerRadius)
        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: direction, cornerRadii: cornerSize)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        layer.addSublayer(maskLayer)
        layer.mask = maskLayer
    }
    
    /// x
    var x: CGFloat {
        get {
            return frame.origin.x
        }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.origin.x    = newValue
            frame                 = tempFrame
        }
    }
    
    /// y
    var y: CGFloat {
        get {
            return frame.origin.y
        }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.origin.y    = newValue
            frame                 = tempFrame
        }
    }
    
    var trailing: CGFloat {
        get {
            return frame.origin.x + frame.size.width
        }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.origin.x    = newValue - tempFrame.size.width
            frame                 = tempFrame
        }
    }
    
    var bottom: CGFloat {
        get {
            return frame.origin.y + frame.size.height
        }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.origin.y    = newValue - tempFrame.size.height
            frame                 = tempFrame
        }
    }
    
    /// height
    var height: CGFloat {
        get {
            return frame.size.height
        }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.size.height = newValue
            frame                 = tempFrame
        }
    }
    
    /// width
    var width: CGFloat {
        get {
            return frame.size.width
        }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.size.width = newValue
            frame = tempFrame
        }
    }
    
    /// size
    var size: CGSize {
        get {
            return frame.size
        }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.size = newValue
            frame = tempFrame
        }
    }
    
    /// centerX
    var centerX: CGFloat {
        get {
            return center.x
        }
        set(newValue){
            var tempCenter: CGPoint = center
            tempCenter.x = newValue
            center = tempCenter
        }
    }
    
    /// centerY
    var centerY: CGFloat {
        get {
            return center.y
        }
        set(newValue) {
            var tempCenter: CGPoint = center
            tempCenter.y = newValue
            center = tempCenter
        }
    }
    
    @IBInspectable var layerCornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var masksToBounds: Bool {
        get {
            return layer.masksToBounds
        }
        set {
            layer.masksToBounds = newValue
        }
    }
    
    static func loadNib<T: UIView>(_ viewClass: T.Type, owner: Any? = nil, options: [UINib.OptionsKey : Any]? = nil) -> T {
        let viewClassName = getClassName(viewClass)
        let bundle = Bundle(for: viewClass)
        guard let nibView = bundle.loadNibNamed(viewClassName,
                                                  owner: owner,
                                                  options: options)?.last as? T
            else { fatalError("can not load nib") }
        return nibView
    }
    
    static func loadXib<T: UIView>(_ viewClass: T.Type, owner: Any? = nil, options: [UINib.OptionsKey : Any]? = nil) -> UIView {
        let viewClassName = getClassName(viewClass)
        let bundle = Bundle(for: viewClass)
        guard
            let nibView = UINib(nibName: viewClassName, bundle: bundle).instantiate(withOwner: owner, options: options).first
                as? UIView
        else { fatalError("can not load nib") }
        return nibView
    }
}
