//
//  DetailViewController.swift
//  SubCreator
//
//  Created by ripple_k on 2019/7/31.
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
        self.cardView.image = image
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
    let reportButton = UIButton(type: .custom).then {
        $0.setTitle("违规举报", for: .normal)
        let title = NSMutableAttributedString(string: "违规举报")
        let strRange = NSRange.init(location: 0, length: title.length)
        let number = NSNumber(value: NSUnderlineStyle.single.rawValue)
        let color = UIColor(hex: 0xAEB7C5)
        title.addAttribute(.underlineStyle, value: number, range: strRange)
        title.addAttribute(.foregroundColor, value: color, range: strRange)
        title.addAttribute(.underlineColor, value: color, range: strRange)
        $0.setAttributedTitle(title, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .regular)
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
            .do(onNext: { [weak self] (isSelected) in
                guard var item = self?.item else { return }
                if isSelected {
                    item.timestamp = Date().timeIntervalSince1970
                    CollectSubtitlesCacher.shared.add(item)
                    message(.success, title: "已成功收藏", body: "请在“我的收藏”中进行查看")
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
            .subscribe(onNext: { [unowned self] (_) in
                if Permission.photos.status == .denied {
                    self.p_gotoPermission(message: "相册")
                    return
                }
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
        
        self.reportButton
            .rx.tap
            .subscribe(onNext: { [weak self] in self?.confirmAlert(title: "举报", message: "确定要举报该内容吗？", confirmAction: {
                message(.success, title: "举报成功", body: "已收到您的举报，感谢您的监督。")
            })})
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
        
        reportButton
            .mt.adhere(toSuperView: view)
            .mt.layout { (make) in
                make.right.equalTo(-35)
                make.top.equalTo(cardView.snp.bottom).offset(3)
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
    private func confirmAlert(title: String,
                              message: String,
                              confirmAction: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "确认", style: .default, handler: { (action) in
            confirmAction()
        }))
        alertController.addAction(UIAlertAction(title: "取消", style: .default, handler: { (action) in
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    private func p_gotoPermission(message: String) {
        UIAlertController
            .present(in: self,
                     title: "您拒绝了该权限，功能无法正常使用。",
                     message: "请到系统”设置-搞笑字幕“中授权使用你的\(message)",
                style: .alert,
                actions: [UIAlertController.AlertAction.action(title: "去设置")])
            .subscribe(onNext: { (_) in
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                        //                        UIApplication.shared.openURL(settingsUrl)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
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
