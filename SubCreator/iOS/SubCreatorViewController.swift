//
//  SubCreatorViewController.swift
//  SubCreator
//
//  Created by rpple_k on 2019/7/31.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SubCreatorViewController: BaseViewController {

    // MARK: - Properties
    // MARK: - Initialized
    // MARK: - UI properties
    let cardView = UIImageView().then {
        $0.layer.applySketchShadow(color: UIColor.mt.shadow, alpha: 1, x: 0, y: 0, blur: 10, spread: 0)
    }
    let backButton = UIButton(type: .custom).then {
        $0.setImage(R.image.navigation_bar_back(), for: .normal)
        $0.sizeToFit()
    }
    let doneButton = UIButton(type: .custom).then {
        $0.setImage(R.image.navigation_bar_save(), for: .normal)
        $0.sizeToFit()
    }
    let saveButton = UIButton(type: .custom).then {
        $0.setImage(R.image.btn_save(), for: .normal)
        $0.sizeToFit()
    }
    let shareButton = UIButton(type: .custom).then {
        $0.setImage(R.image.share_wechat(), for: .normal)
        $0.sizeToFit()
    }
    let collectButton = UIButton(type: .custom).then {
        $0.setImage(R.image.btn_collection(), for: .normal)
        $0.sizeToFit()
    }
    let toolBar = SubCreatorToolBar(frame: CGRect(x: 0, y: screenHeight - 50, width: screenWidth, height: 50))
    
    // MARK: - View Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hero.isEnabled = true
        //        cardView.hero.id = "card"
        //        subCreatorButton.hero.id = "bottomButton"
        //        cardView.hero.modifiers = [.cascade]
        cardView.hero.modifiers = [.scale()]
        cardView.image = R.image.图()
        self.backButton.rx.tap
            .bind(to: self.rx.dismiss())
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - SEL
    // MARK: - Layout
    override func setupConstraints() {
        backButton
            .mt.adhere(toSuperView: view)
            .mt.layout { (make) in
                make.left.equalTo(5)
                make.top.equalTo(25)
        }
        
        doneButton
            .mt.adhere(toSuperView: view)
            .mt.layout { (make) in
                make.right.equalTo(-5)
                make.top.equalTo(25)
        }
        
        view.insertSubview(cardView, belowSubview: backButton)
        cardView
            .mt.layout { (make) in
                make.centerX.equalToSuperview()
                make.top.equalTo(backButton.snp.centerY)
                make.size.equalTo(screenWidth - 45 * 2)
        }
        
        shareButton
            .mt.adhere(toSuperView: view)
            .mt.layout { (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalTo(cardView.snp.bottom)
        }
        
        saveButton
            .mt.adhere(toSuperView: view)
            .mt.layout { (make) in
                make.centerX.equalTo(cardView).offset(-(screenWidth - 45 * 2) / 4)
                make.centerY.equalTo(shareButton)
        }
        
        collectButton
            .mt.adhere(toSuperView: view)
            .mt.layout { (make) in
                make.centerX.equalTo(cardView).offset((screenWidth - 45 * 2) / 4)
                make.centerY.equalTo(shareButton)
        }
        
        view.addSubview(toolBar)
    }
    // MARK: - Private Functions
}

enum ToolBarItem {
    case face
    case style
}

class SubCreatorToolBar: BaseView {
    var items: [ToolBarItem] = [.face, .style]
    var event = PublishRelay<ToolBarItem>()
    
    private let disposeBag = DisposeBag()
    
    override func setupSubviews() {
        backgroundColor = UIColor.white
        layer.applySketchShadow(color: UIColor.mt.shadow, alpha: 1, x: 0, y: 1, blur: 1, spread: 0)
        var previousView: UIView?
        items.forEach { (item) in
            let button = UIButton(type: .custom)
            switch item {
            case .face:
                button.setImage(R.image.toobar_item_face(), for: .normal)
                button.rx.tap
                    .map { ToolBarItem.face }
                    .bind(to: event)
                    .disposed(by: disposeBag)
            case .style:
                button.setImage(R.image.toobar_item_style(), for: .normal)
                button.rx.tap
                    .map { ToolBarItem.style }
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
