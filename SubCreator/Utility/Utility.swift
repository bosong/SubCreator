//
//  Utility.swift
//  DramaUIKit
//
//  Created by MorningStar on 2018/11/13.
//  Copyright © 2018 FeiZaoTai. All rights reserved.
//

import Foundation
import UIKit

public var designWidth: (CGFloat) -> (CGFloat) {
    return { value in
        return value / 375 * screenWidth
    }
}

public var designHeight: (CGFloat) -> (CGFloat) {
    return { value in
        return value / 667 * screenHeight
    }
}

public let screenAspectRatio = screenWidth / screenHeight

public func synced(_ lock: Any, closure: () -> Void) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}

/// 区间随机数生成器
///
/// - Parameter range: 随机数生成区间
/// - Returns: 区间内随机数
public func random(in range: Range<Int>) -> Int {
    return Int.random(in: range.lowerBound..<range.upperBound)
//    let count = UInt32(range.upperBound - range.lowerBound)
//    return Int(arc4random_uniform(count)) + range.lowerBound
}

/// 找到view所在的controller
///
/// - Parameter view: view
/// - Returns: controller
public func findViewController(view: UIView?) -> UIViewController {
    if view == nil {
        return (UIApplication.shared.keyWindow?.rootViewController?.children.first) ?? UIViewController()
    } else {
        var target: UIResponder? = view!
        while target != nil {
            target = target!.next
            if target is UIViewController {
                return (target as? UIViewController) ?? UIViewController()
            }
        }
    }
    return (UIApplication.shared.keyWindow?.rootViewController?.children.first) ?? UIViewController()
}

typealias MyTask = (_ cancel: Bool) -> Void
/// 延时执行函数
///
/// - Parameters:
///   - time: 延时时长
///   - task: 要执行的闭包
/// - Returns: 可取消的可执行闭包
@discardableResult
func delay(_ time: TimeInterval, task:@escaping () -> Void) -> MyTask? {
    
    func dispatch_later(closure:@escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time, execute: closure)
    }
    
    var closure: (() -> Void)? = task
    var result: MyTask?
    let delayedClosure: MyTask = {
        cancel in
        if let closure = closure {
            if cancel == false {
                closure()
            }
        }
        closure = nil
        result = nil
    }
    
    result = delayedClosure
    
    dispatch_later {
        delayedClosure(false)
    }
    
    return result
}
