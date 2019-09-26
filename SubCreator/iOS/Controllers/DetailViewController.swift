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
    private var item: Subtitles?
    // MARK: - Initialized
    init(image: UIImage, item: Subtitles? = nil) {
        super.init(nibName: nil, bundle: nil)
        cardView.image = image
        self.collectButton.isHidden = item.isNone
//        self.materialRefersButton.isHidden = item.isNone
        if let item = item {
            self.item = item
            self.collectButton.isSelected = CollectSubtitlesCacher.shared.loads().contains(item)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - UI properties
    let cardView = CardView()
//    let backButton = UIButton(type: .custom).then {
//        $0.setImage(R.image.navigation_bar_back(), for: .normal)
//        $0.sizeToFit()
//    }
//    let materialRefersButton = UIButton(type: .custom).then {
//        $0.setImage(R.image.btn_material_refers(), for: .normal)
//        $0.sizeToFit()
//    }
//    let subCreatorButton = UIButton(type: .custom).then {
//        $0.setImage(R.image.btn_make(), for: .normal)
//    }
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
    let dismissTapGesture = UITapGestureRecognizer()
    
    // MARK: - View Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hero.isEnabled = true
//        backButton.hero.id = "navigationItem"
        cardView.hero.modifiers = [.arc()]
        shareButton.hero.modifiers = [.arc()]
        saveButton.hero.modifiers = [.arc()]
        collectButton.hero.modifiers = [.arc()]
        view.addGestureRecognizer(dismissTapGesture)
//        subCreatorButton.hero.modifiers = [.arc()]
//        cardView.image = R.image.图()
//        self.backButton.rx.tap
//            .bind(to: self.rx.dismiss())
//            .disposed(by: disposeBag)
//
//        self.materialRefersButton.rx.tap
//            .subscribe(onNext: { [weak self] in
//                guard let id = self?.item?.materialId, id.isNotEmpty else { return }
//                let vc = MaterialRefersViewController(reactor: MaterialRefersViewReactor(id: id))
//                self?.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
//            })
//            .disposed(by: disposeBag)
//
//        self.subCreatorButton.rx.tap
//            .subscribe(onNext: { [unowned self] (_) in
//                guard let image = self.cardView.image else { return }
//                let subCreatorVC = SubCreatorViewController(image: image, item: self.item)
//                subCreatorVC.cardView.hero.id = self.cardView.hero.id
//                subCreatorVC.backButton.hero.id = self.backButton.hero.id
//                subCreatorVC.doneButton.hero.id = self.backButton.hero.id
//                subCreatorVC.saveButton.hero.id = self.saveButton.hero.id
//                subCreatorVC.shareButton.hero.id = self.shareButton.hero.id
//                subCreatorVC.collectButton.hero.id = self.collectButton.hero.id
//                self.present(subCreatorVC, animated: true, completion: nil)
//            })
//            .disposed(by: disposeBag)
        
        self.collectButton.rx.tap
            .map { [unowned self] in !self.collectButton.isSelected }
            .do(onNext: { (isSelected) in
                guard let item = self.item else { return }
                if isSelected {
                    CollectSubtitlesCacher.shared.add(item)
                    message(.success, title: "已成功收藏，请在“我的收藏”中进行查看")
                } else {
                    CollectSubtitlesCacher.shared.remove(item)
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
        
        dismissTapGesture
            .rx.event
            .subscribe(onNext: { [weak self] (tap) in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - SEL
    // MARK: - Layout
    override func setupConstraints() {
//        backButton
//            .mt.adhere(toSuperView: view)
//            .mt.layout { (make) in
//                make.left.equalTo(5)
//                make.top.equalTo(25)
//        }
//
//        materialRefersButton
//            .mt.adhere(toSuperView: view)
//            .mt.layout { (make) in
//                make.right.equalTo(-5)
//                make.centerY.equalTo(backButton)
//        }
        
        cardView
            .mt.adhere(toSuperView: view)
            .mt.layout { (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(-50)
                let cardWidth = screenWidth - 30 * 2
                let cardHeight = cardWidth * HomepageViewController.Metric.itemRatio
                make.size.equalTo(CGSize(width: cardWidth, height: cardHeight))
        }
        
        shareButton
            .mt.adhere(toSuperView: view)
            .mt.layout { (make) in
                make.centerX.equalTo(cardView).offset((screenWidth - 30 * 2) / 3)
                make.top.equalTo(cardView.snp.bottom).offset(20)
        }
        
        saveButton
            .mt.adhere(toSuperView: view)
            .mt.layout { (make) in
                make.centerX.equalTo(cardView).offset(-(screenWidth - 30 * 2) / 3)
                make.centerY.equalTo(shareButton)
        }
        
        collectButton
            .mt.adhere(toSuperView: view)
            .mt.layout { (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalTo(shareButton)
        }
        
//        subCreatorButton
//            .mt.adhere(toSuperView: view)
//            .mt.layout { (make) in
//                make.bottom.equalTo(-60 - safeAreaBottomMargin)
//                make.centerX.equalToSuperview()
//        }
    }
    // MARK: - Private Functions

}

class CardView: BaseView {
    var image: UIImage? {
        set {
            self.imageView.image = newValue
        }
        get {
            return self.imageView.image
        }
    }
    let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 3
        $0.clipsToBounds = true
        $0.isUserInteractionEnabled = true
    }
    override func setupSubviews() {
        layer.applySketchShadow(color: UIColor.mt.shadow, alpha: 1, x: 0, y: 0, blur: 10, spread: 0)
        layer.cornerRadius = 3
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        isUserInteractionEnabled = true
        imageView
            .mt.adhere(toSuperView: self)
            .mt.layout { (make) in
                make.edges.equalToSuperview()
        }
    }
}
