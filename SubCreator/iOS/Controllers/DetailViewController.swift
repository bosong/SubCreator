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
    private var item: HomeItem?
    // MARK: - Initialized
    init(image: UIImage, item: HomeItem? = nil) {
        super.init(nibName: nil, bundle: nil)
        cardView.image = image
        self.collectButton.isHidden = item.isNone
        self.materialRefersButton.isHidden = item.isNone
        if let item = item {
            self.item = item
            self.collectButton.isSelected = CollectCacher.shared.loads().contains(item)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - UI properties
    let cardView = UIImageView().then {
        $0.layer.applySketchShadow(color: UIColor.mt.shadow, alpha: 1, x: 0, y: 0, blur: 10, spread: 0)
    }
    let backButton = UIButton(type: .custom).then {
        $0.setImage(R.image.navigation_bar_back(), for: .normal)
        $0.sizeToFit()
    }
    let materialRefersButton = UIButton(type: .custom).then {
        $0.setImage(R.image.btn_material_refers(), for: .normal)
        $0.sizeToFit()
    }
    let subCreatorButton = UIButton(type: .custom).then {
        $0.setImage(R.image.btn_make(), for: .normal)
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
        $0.setImage(R.image.btn_collection_normal(), for: .normal)
        $0.setImage(R.image.btn_collection_sel(), for: .selected)
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
//        cardView.image = R.image.图()
        self.backButton.rx.tap
            .bind(to: self.rx.dismiss())
            .disposed(by: disposeBag)
        
        self.materialRefersButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let id = self?.item?.uid, id.isNotEmpty else { return }
                let vc = MaterialRefersViewController(reactor: MaterialRefersViewReactor(id: id))
                self?.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        self.subCreatorButton.rx.tap
            .subscribe(onNext: { [unowned self] (_) in
                guard let image = self.cardView.image else { return }
                guard let item = self.item else { return }
                let subCreatorVC = SubCreatorViewController(image: image, item: item)
                subCreatorVC.cardView.hero.id = self.cardView.hero.id
                subCreatorVC.backButton.hero.id = self.backButton.hero.id
                subCreatorVC.doneButton.hero.id = self.backButton.hero.id
                subCreatorVC.saveButton.hero.id = self.saveButton.hero.id
                subCreatorVC.shareButton.hero.id = self.shareButton.hero.id
                subCreatorVC.collectButton.hero.id = self.collectButton.hero.id
                self.present(subCreatorVC, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        self.collectButton.rx.tap
            .map { [unowned self] in !self.collectButton.isSelected }
            .do(onNext: { (isSelected) in
                guard let item = self.item else { return }
                if isSelected {
                    CollectCacher.shared.add(item)
                    message(.success, title: "已成功收藏，请在“我的收藏”中进行查看")
                } else {
                    CollectCacher.shared.remove(item)
                    message(.success, title: "已取消收藏")
                }
            })
            .bind(to: self.collectButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        self.shareButton.rx.tap
            .subscribe(onNext: { [unowned self] (_) in
                Share.shareShow(controller: self, items: [self.cardView.asImage()])
            })
            .disposed(by: disposeBag)
        
        self.saveButton.rx.tap
            .subscribe(onNext: { (_) in
                SaveImageTools.shared.saveImage(self.cardView.asImage(), completed: { (error) in
                    error.noneDo {
                        DispatchQueue.main.async {
                            message(.success, title: "已保存到手机相册")
                        }
                    }
                })
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
        
        materialRefersButton
            .mt.adhere(toSuperView: view)
            .mt.layout { (make) in
                make.right.equalTo(-5)
                make.centerY.equalTo(backButton)
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
                make.centerX.equalTo(cardView).offset((screenWidth - 45 * 2) / 4)
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
                make.centerX.equalToSuperview()
                make.centerY.equalTo(shareButton)
        }
        
        subCreatorButton
            .mt.adhere(toSuperView: view)
            .mt.layout { (make) in
                make.bottom.equalTo(-60 - safeAreaBottomMargin)
                make.centerX.equalToSuperview()
        }
    }
    // MARK: - Private Functions

}
