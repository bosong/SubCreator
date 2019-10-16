//
//  SwiftyMessageHelper.swift
//  ACG
//
//  Created by ripple_k on 2019/1/11.
//  Copyright © 2019 SoapVideo. All rights reserved.
//
//  swiftlint:disable vertical_parameter_alignment

import SwiftMessages

func message(_ theme: Theme,
                     layout: MessageView.Layout = .messageView,
                     position: SwiftMessages.PresentationStyle = .top,
                     level: SwiftMessages.PresentationContext = .window(windowLevel: UIWindow.Level.normal),
                     duration: SwiftMessages.Duration = .seconds(seconds: 2),
                     dimMode: SwiftMessages.DimMode = .none,
                     title: String? = nil, body: String? = nil,
                     iconImage: UIImage? = nil, iconText: String? = nil,
                     buttonImage: UIImage? = nil, buttonTitle: String? = nil,
                     buttonTapHandler: ((UIButton) -> Void)? = nil) {
    let view = MessageView.viewFromNib(layout: layout)
    
    view.configureContent(title: title, body: body, iconImage: iconImage,
                          iconText: iconText, buttonImage: buttonImage,
                          buttonTitle: buttonTitle, buttonTapHandler: buttonTapHandler)
    let iconStyle: IconStyle = .light
    view.configureTheme(theme, iconStyle: iconStyle)
    view.configureDropShadow()
    
    var config = SwiftMessages.defaultConfig
    config.presentationStyle = .top
    config.presentationContext = level
    config.duration = duration
    config.dimMode = dimMode
    config.shouldAutorotate = true
    
    if buttonImage.isNone, buttonTitle.isNone, buttonTapHandler.isNone {
        view.button?.isHidden = true
    }
    
    SwiftMessages.show(config: config, view: view)
}

func messageCenter(title: String? = nil, body: String? = nil,
                   iconImage: UIImage? = nil, iconText: String? = nil,
                   buttonImage: UIImage? = nil, buttonTitle: String? = nil,
                   buttonTapHandler: ((UIButton) -> Void)? = nil) {
    let messageView: MessageView = MessageView.viewFromNib(layout: .centeredView)
    messageView.configureBackgroundView(width: 250)
    messageView.configureContent(title: title, body: body, iconImage: iconImage,
                                 iconText: iconText, buttonImage: buttonImage,
                                 buttonTitle: buttonTitle, buttonTapHandler: buttonTapHandler)
    messageView.backgroundView.backgroundColor = UIColor.init(white: 0.97, alpha: 1)
    messageView.backgroundView.layer.cornerRadius = 10
    var config = SwiftMessages.defaultConfig
    config.presentationStyle = .center
    config.duration = .forever
    config.dimMode = .blur(style: .dark, alpha: 1, interactive: true)
    config.presentationContext  = .window(windowLevel: UIWindow.Level.statusBar)
    SwiftMessages.show(config: config, view: messageView)
}

class SwiftMessagesCenteredSegue: SwiftMessagesSegue {
    override public init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        configure(layout: .centered)
        let leftRightEdge: CGFloat = (screenWidth - 342) / 2
        messageView.layoutMarginAdditions = UIEdgeInsets(top: 20, left: leftRightEdge, bottom: 20, right: leftRightEdge)
    }
}
