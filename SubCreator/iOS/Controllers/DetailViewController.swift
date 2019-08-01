//
//  DetailViewController.swift
//  SubCreator
//
//  Created by rpple_k on 2019/7/31.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import UIKit
import Hero

class DetailViewController: BaseViewController {

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
    let subCreatorButton = UIButton(type: .custom).then {
        $0.setTitle("我来制作", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.setBackgroundImage(UIImage.resizable().color(UIColor.mt.theme).corner(radius: 40).image, for: .normal)
        $0.layer.applySketchShadow(color: UIColor.mt.shadow, alpha: 1, x: 0, y: 0, blur: 10, spread: 0)
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
    
    // MARK: - View Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hero.isEnabled = true
        backButton.hero.id = "navigationItem"
        cardView.hero.modifiers = [.arc()]
        shareButton.hero.modifiers = [.arc()]
        saveButton.hero.modifiers = [.arc()]
        collectButton.hero.modifiers = [.arc()]
        subCreatorButton.hero.modifiers = [.arc()]
        cardView.image = R.image.图()
        self.backButton.rx.tap
            .bind(to: self.rx.dismiss())
            .disposed(by: disposeBag)
        self.subCreatorButton.rx.tap
            .subscribe(onNext: { [unowned self] (_) in
                let subCreatorVC = SubCreatorViewController()
                subCreatorVC.cardView.hero.id = self.cardView.hero.id
                subCreatorVC.backButton.hero.id = self.backButton.hero.id
                subCreatorVC.doneButton.hero.id = self.backButton.hero.id
                subCreatorVC.saveButton.hero.id = self.saveButton.hero.id
                subCreatorVC.shareButton.hero.id = self.shareButton.hero.id
                subCreatorVC.collectButton.hero.id = self.collectButton.hero.id
                self.present(subCreatorVC, animated: true, completion: nil)
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
    // MARK: - Layout
    override func setupConstraints() {
        backButton
            .mt.adhere(toSuperView: view)
            .mt.layout { (make) in
                make.left.equalTo(5)
                make.top.equalTo(25)
        }
        
        cardView
            .mt.adhere(toSuperView: view)
            .mt.layout { (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(-50)
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
        
        subCreatorButton
            .mt.adhere(toSuperView: view)
            .mt.layout { (make) in
                make.bottom.equalTo(-80 - safeAreaBottomMargin)
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 80, height: 80))
        }
    }
    // MARK: - Private Functions

}
