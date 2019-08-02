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

    struct Metric {
        static let styleItemViewHeight: CGFloat = 217
        static let cardViewSize = CGSize(width: screenWidth - 45 * 2, height: screenWidth - 45 * 2)
        static func textLableFont(size: CGFloat) -> UIFont {
            return UIFont(name: "GJJHPJW--GB1-0", size: size) ?? UIFont.systemFont(ofSize: size)
        }
    }
    // MARK: - Properties
    // MARK: - Initialized
    // MARK: - UI properties
    let cardView = UIImageView(frame: CGRect(origin: .zero, size: Metric.cardViewSize)).then {
        $0.layer.applySketchShadow(color: UIColor.mt.shadow, alpha: 1, x: 0, y: 0, blur: 10, spread: 0)
        $0.isUserInteractionEnabled = true
    }
    let textLabel = UILabel().then {
        $0.textColor = UIColor.black
        $0.font = Metric.textLableFont(size: 28)
        $0.numberOfLines = 0
        $0.isUserInteractionEnabled = true
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
    let toolBarStyleItemView = ToolBarStyleItemView()
    var toolBarSel: ToolBarItem = .style
    
    // MARK: - View Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hero.isEnabled = true
        cardView.hero.modifiers = [.scale()]
        cardView.image = R.image.图()
        self.backButton.rx.tap
            .bind(to: self.rx.dismiss())
            .disposed(by: disposeBag)
        
        toolBar.event
            .subscribe(onNext: { [unowned self] (item) in
                self.toolBarSel = item
                switch item {
                case .text:
                    self.inputTextView.textView.becomeFirstResponder()
                case .face:
                    break
                case .style:
                    self.toolBarStyleItemView.removeFromSuperview()
                    self.inputTextView.textView.resignFirstResponder()
                    self.view.insertSubview(self.toolBarStyleItemView, belowSubview: self.toolBar)
                    self.toolBarStyleItemView.y = screenHeight
                    UIView.animate(withDuration: 0.3, animations: {
                        self.toolBarStyleItemView.bottom = screenHeight
                        self.toolBar.bottom = self.toolBarStyleItemView.y
                    })
                }
            })
            .disposed(by: disposeBag)
        
        inputTextView
            .textViewHeightObservable
            .subscribe(onNext: { [unowned self] (_) in
                guard self.toolBarSel == .text else { return }
                self.toolBar.bottom = self.inputTextView.y
            })
            .disposed(by: disposeBag)
        
        inputTextView.textView.rx.text
            .bind(to: textLabel.rx.text)
            .disposed(by: disposeBag)
        
        toolBarStyleItemView.colorSwitchView
            .colorSelectedBehavior
            .asObservable()
            .subscribe(onNext: { [unowned self] (color) in
                self.textLabel.textColor = color
            })
            .disposed(by: disposeBag)
        
        toolBarStyleItemView.fontSliderView
            .rx.controlEvent(.valueChanged)
            .map { [unowned self] in self.toolBarStyleItemView.fontSliderView.fraction * 100}
            .subscribe(onNext: { [unowned self] (value) in
                self.textLabel.font = Metric.textLableFont(size: value)
            })
            .disposed(by: disposeBag)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(rotateGesture(_:)))
        textLabel.addGestureRecognizer(pan)
        cardView.addGestureRecognizer(rotate)
        
        self.saveButton.rx.tap
            .subscribe(onNext: { (_) in
                let arr = Array(self.textLabel.text ?? "")
                self.textLabel.text = arr.map { $0.description }.joined(separator: "\n")
            })
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
    @objc func panGesture(_ gesture: UIPanGestureRecognizer) {
        let point = gesture.location(in: self.cardView)
        self.textLabel.transform.tx = point.x - textLabel.center.x
        self.textLabel.transform.ty = point.y - textLabel.center.y

    }
    
    var textLabelRotation: CGFloat = 0
    @objc func rotateGesture(_ gesture: UIRotationGestureRecognizer) {
        textLabel.transform = textLabel.transform.rotated(by: gesture.rotation)
        gesture.rotation = 0
    }
    
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
                make.size.equalTo(Metric.cardViewSize)
        }
        
        textLabel
            .mt.adhere(toSuperView: cardView)
            .mt.layout { (make) in
                make.center.equalToSuperview()
                make.size.lessThanOrEqualTo(cardView)
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
        
        view.addSubview(self.inputTextView)
        view.addSubview(toolBar)
    }
    // MARK: - Private Functions
}
