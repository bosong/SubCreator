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
import fluid_slider

enum ToolBarItem {
    case face
    case style
    case text
}

class SubCreatorToolBar: BaseView {
    enum TextAlignment {
        case horizontal
        case vertical
    }
    
    var currentSelected = BehaviorRelay<ToolBarItem>(value: .text)
    lazy var textAlignmentObserVable = self.textAlignmentBehavior.asObservable().distinctUntilChanged()
    var toolBarInputView: UIView?
    
    private let items: [ToolBarItem] = [.style, .text]
    private let disposeBag = DisposeBag()
    private var buttons: [UIButton] = []
    private let textAlignmentH = UIButton(type: .custom)
    private let textAlignmentV = UIButton(type: .custom)
    private let textAlignmentBehavior = BehaviorRelay<TextAlignment>(value: .horizontal)
    
    override var inputView: UIView? {
        set {
            self.resignFirstResponder()
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
            let button = self.prepareItem(item)
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
        
        textAlignmentV
            .mt.config { (button) in
                button.setImage(R.image.btn_text_alignmentV_sel(), for: .selected)
                button.setImage(R.image.btn_text_alignmentV_normal(), for: .normal)
                button.sizeToFit()
            }
            .mt.adhere(toSuperView: self)
            .mt.layout { (make) in
                make.right.equalToSuperview().offset(-20)
                make.height.equalToSuperview()
        }
        
        textAlignmentH
            .mt.config { (button) in
                button.setImage(R.image.btn_text_alignmentH_sel(), for: .selected)
                button.setImage(R.image.btn_text_alignmentH_normal(), for: .normal)
                button.isSelected = true
                button.sizeToFit()
            }
            .mt.adhere(toSuperView: self)
            .mt.layout { (make) in
                make.right.equalTo(textAlignmentV.snp.left).offset(-15)
                make.height.equalToSuperview()
        }
        
        let alignmentTapped = Observable.merge(
            textAlignmentV.rx.tap.map { TextAlignment.vertical }.asObservable(),
            textAlignmentH.rx.tap.map { TextAlignment.horizontal }.asObservable()
        ).share()
        
        alignmentTapped
            .map { $0 == .horizontal }
            .bind(to: self.textAlignmentH.rx.isSelected)
            .disposed(by: disposeBag)
        
        alignmentTapped
            .map { $0 == .vertical }
            .bind(to: self.textAlignmentV.rx.isSelected)
            .disposed(by: disposeBag)
        
        alignmentTapped
            .bind(to: textAlignmentBehavior)
            .disposed(by: disposeBag)
    }
    
    private func prepareItem(_ item: ToolBarItem) -> UIButton {
        let button = UIButton(type: .custom)
        buttons.append(button)
        switch item {
        case .face:
            button.setImage(R.image.toobar_item_face(), for: .normal)
            let tapped = button.rx.tap.map { ToolBarItem.face }.share()
            tapped
                .bind(to: currentSelected)
                .disposed(by: disposeBag)
        case .style:
            button.setImage(R.image.toobar_item_style_notmal(), for: .normal)
            button.setImage(R.image.toobar_item_style_sel(), for: .selected)
            let tapped = button.rx.tap.map { ToolBarItem.style }
            tapped
                .bind(to: currentSelected)
                .disposed(by: disposeBag)
        case .text:
            button.setImage(R.image.toobar_item_text_normal(), for: .normal)
            button.setImage(R.image.toobar_item_text_sel(), for: .selected)
            let tapped = button.rx.tap.map { ToolBarItem.text }
            tapped
                .bind(to: currentSelected)
                .disposed(by: disposeBag)
        }
        button.sizeToFit()
        return button
    }
}

class ToolBarStyleItemView: BaseView {
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 217))
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    let colorSwitchView = ColorSwitchView()
    let fontSliderView = Slider().then { (slider) in
        slider.attributedTextForFraction = { fraction in
            let formatter = NumberFormatter()
            formatter.maximumIntegerDigits = 3
            formatter.maximumFractionDigits = 0
            let string = formatter.string(from: (fraction * 100) as NSNumber) ?? ""
            let attrStr = NSAttributedString(string: string, attributes: [.font: UIFont.systemFont(ofSize: 8)])
            return attrStr
        }
        slider.setMinimumLabelAttributedText(NSAttributedString(string: "💤"))
        slider.setMaximumLabelAttributedText(NSAttributedString(string: "100"))
        slider.fraction = 0.3
        slider.shadowOffset = CGSize(width: 0, height: 10)
        slider.shadowBlur = 5
        slider.shadowColor = UIColor(white: 0, alpha: 0.1)
        slider.contentViewColor = UIColor.mt.theme
        slider.valueViewColor = .white
    }
    let textDirectionButton = UIButton(type: .custom)
    
    private let helpLabel = UILabel().then {
        $0.textColor = UIColor(hex: 0x999999)
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.numberOfLines = 0
        let text =
        """
            帮助说明\n
            *可两指操作拖动、旋转文字\n
            *文字颜色可更改\n
            *可改变文字的横纵方向
        """
        
        let attrText = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0
        paragraphStyle.lineHeightMultiple = 0.7
        paragraphStyle.lineBreakMode = $0.lineBreakMode
        paragraphStyle.alignment = $0.textAlignment
        attrText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))
        $0.attributedText = attrText
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
    
    class ColorSwitchView: BaseView {
        let colors = [
            UIColor(hex: 0xED6466), UIColor(hex: 0xEA66C6),
            UIColor(hex: 0xB462E8), UIColor(hex: 0x45ABFF),
            UIColor(hex: 0x62E9DA), UIColor(hex: 0xEDDA69),
            UIColor(hex: 0xEAAF66), UIColor(hex: 0xEA8060),
            UIColor(hex: 0xFEFEFE), UIColor(hex: 0x010101)
        ]
        let colorSelectedBehavior = BehaviorRelay<UIColor>(value: UIColor(hex: 0x010101))
        private let disposeBag = DisposeBag()
        
        override func setupSubviews() {
            layer.borderWidth = 4
            layer.borderColor = UIColor.white.cgColor
            let buttons = colors.map { (color) -> UIButton in
                let button = UIButton(type: .custom)
                button.setBackgroundImage(UIImage.resizable().color(color).image, for: .normal)
                button.rx.tap
                    .map { color }
                    .bind(to: self.colorSelectedBehavior)
                    .disposed(by: disposeBag)
                return button
            }
            let stackView = UIStackView(arrangedSubviews: buttons)
            stackView.alignment = .center
            stackView.spacing = 0
            stackView.distribution = .fillEqually
            stackView.axis = .horizontal
            stackView
                .mt.adhere(toSuperView: self)
                .mt.layout { (make) in
                    make.edges.equalToSuperview()
            }
        }
    }
}
