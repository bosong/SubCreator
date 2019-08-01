//
//  SubCreatorToolBar.swift
//  SubCreator
//
//  Created by rpple_k on 2019/8/1.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum ToolBarItem {
    case face
    case style
    case text
}

class SubCreatorToolBar: BaseView {
    var event = PublishRelay<ToolBarItem>()
    var currentSelected = BehaviorRelay<ToolBarItem>(value: .style)
    var toolBarInputView: UIView = UIView()
    private let items: [ToolBarItem] = [.face, .style, .text]
    private let disposeBag = DisposeBag()
    
    override var inputView: UIView {
        set {
            self.toolBarInputView = newValue
            self.becomeFirstResponder()
        }
        get {
            return self.toolBarInputView
        }
    }
    override var canBecomeFocused: Bool {
        return true
    }
    
    override func setupSubviews() {
        backgroundColor = UIColor.white
        layer.applySketchShadow(color: UIColor.mt.shadow, alpha: 1, x: 0, y: 1, blur: 1, spread: 0)
        var previousView: UIView?
        items.forEach { (item) in
            let button = UIButton(type: .custom)
            switch item {
            case .face:
                button.setImage(R.image.toobar_item_face(), for: .normal)
                let tapped = button.rx.tap.map { ToolBarItem.face }.share()
                tapped
                    .bind(to: event)
                    .disposed(by: disposeBag)
                tapped
                    .bind(to: currentSelected)
                    .disposed(by: disposeBag)
            case .style:
                button.setImage(R.image.toobar_item_style(), for: .normal)
                let tapped = button.rx.tap.map { ToolBarItem.style }
                tapped
                    .bind(to: event)
                    .disposed(by: disposeBag)
                tapped
                    .bind(to: currentSelected)
                    .disposed(by: disposeBag)
            case .text:
                button.setTitle("字", for: .normal)
                button.rx.tap
                    .map { ToolBarItem.text }
                    .bind(to: event)
                    .disposed(by: disposeBag)
            }
            button.sizeToFit()
            button
                .mt.adhere(toSuperView: self)
                .mt.layout(snapKitMaker: { (make) in
                    if let previousView = previousView {
                        make.left.equalTo(previousView.snp.right).offset(10)
                    } else {
                        make.left.equalToSuperview().offset(15)
                    }
                    make.height.equalToSuperview()
                })
            previousView = button
        }
    }
}

class ToolBarStyleItemView: BaseView {
    
    let colorSwitchView = UIView()
    let fontSliderView = UIView()
    private let helpLabel = UILabel().then {
        $0.textColor = UIColor(hex: 0x999999)
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.text =
        """
        帮助说明\n
        *可两指操作拖动、旋转文字\n
        *文字颜色可更改
        """
    }
    override func setupSubviews() {
        helpLabel
            .mt.adhere(toSuperView: self)
            .mt.layout { (make) in
                make.top.equalTo(25)
                make.left.equalTo(30)
        }
        
        colorSwitchView
            .mt.adhere(toSuperView: self)
            .mt.layout { (make) in
                make.top.equalTo(helpLabel.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
                make.width.equalTo(screenWidth - 60)
                make.height.equalTo(28)
        }
        
        fontSliderView
            .mt.adhere(toSuperView: self)
            .mt.layout { (make) in
                make.top.equalTo(colorSwitchView.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
                make.width.equalTo(colorSwitchView)
                make.height.equalTo(20)
        }
    }
}
