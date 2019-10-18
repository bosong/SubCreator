//
//  Constant.swift
//  SubCreator
//
//  Created by ripple_k on 2019/7/30.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import UIKit

/// 状态栏高度
let statusBarHeight: CGFloat = ((UIApplication.shared.statusBarFrame.height == 0) ?
    (isIphoneX ? 44.0 : 20.0) :
    (UIApplication.shared.statusBarFrame.height))

let screenFrame = UIScreen.main.bounds
let screenWidth = UIScreen.main.bounds.size.width
let screenHeight = UIScreen.main.bounds.size.height

/// 屏幕Size
let screenSize = UIScreen.main.bounds.size

/// Tabbar高度
let tabBarHeight: CGFloat = (isIphoneX ? 83.0 : 49.0)

/// 安全区域顶部高度 == 状态栏高度
let safeAreaTopHeight = (statusBarHeight)

/// 安全区域顶部位移 == IphoneX状态栏高度变化
let safeAreaTopMargin: CGFloat = (isIphoneX ? 24.0 : 0.0)
let safeAreaNavTop: CGFloat = UIApplication.shared.statusBarFrame.size.height + 44

/// 安全区域底部间隙 == 底部进入主屏幕手势标识高度
public let safeAreaBottomMargin: CGFloat = isIphoneX ? 34 : 0

/// iPhoneX
let isIphoneX = Device.isGreatOrEqualToiPhoneX
