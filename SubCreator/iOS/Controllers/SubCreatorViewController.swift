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
    let inputTextView = InputTextView()
    let toolBarStyleItemView = ToolBarStyleItemView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 217))
    
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
        
        toolBar.event
            .subscribe(onNext: { [unowned self] (item) in
                switch item {
                case .text:
                    break
                case .face:
//                    self.inputTextView.textView.resignFirstResponder()
                    
//                    self.inputTextView.textView.inputView = ToolBarStyleItemView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 217))
                    self.toolBar.inputView = self.toolBarStyleItemView
                    self.toolBar.becomeFirstResponder()
                case .style:
                    self.toolBar.inputView = self.inputTextView
                    self.inputTextView.textView.becomeFirstResponder()
                }
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .takeUntil(rx.deallocated)
            .subscribe(onNext: { [weak self] (notification) in
                guard let self = self,
                    let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
                        return
                }
                let size = value.cgRectValue.size
                let keyboardHeight =  UIInterfaceOrientation.portrait.isLandscape ? size.width : size.height
                var toolBarY: CGFloat = 0
                switch self.toolBar.currentSelected.value {
                case .text:
                    toolBarY = screenHeight - self.toolBar.frame.height - keyboardHeight
                case .face:
                    toolBarY = screenHeight - self.toolBar.frame.height - keyboardHeight
                case .style:
                    toolBarY = self.inputTextView.frame.minY - self.toolBar.frame.height
                }
                self.toolBar.frame = CGRect(origin: CGPoint(x: 0, y: toolBarY), size: self.toolBar.frame.size)
            })
            .disposed(by: disposeBag)
//        inputTextView
//            .textViewHeightObservable
//            .subscribe(onNext: { [unowned self] (_) in
//                let toolBarY = self.inputTextView.frame.minY - self.toolBar.frame.height
//                self.toolBar.frame = CGRect(origin: CGPoint(x: 0, y: toolBarY), size: self.toolBar.frame.size)
//            })
//            .disposed(by: disposeBag)
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
        view.addSubview(self.inputTextView)
    }
    // MARK: - Private Functions
}
