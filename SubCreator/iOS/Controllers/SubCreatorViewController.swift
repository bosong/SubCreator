//
//  SubCreatorViewController.swift
//  SubCreator
//
//  Created by ripple_k on 2019/7/31.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional
import Moya

class SubCreatorViewController: BaseViewController {

    struct Metric {
        static let styleItemViewHeight: CGFloat = 217
        static let cardViewSize = CGSize(width: screenWidth - 30 * 2, height: (screenWidth - 30 * 2) * HomepageViewController.Metric.itemRatio)
        static func textLableFont(size: CGFloat) -> UIFont {
            return UIFont(name: "GJJHPJW--GB1-0", size: size) ?? UIFont.systemFont(ofSize: size)
        }
    }
    // MARK: - Properties
    var item: Materials?
    
    // MARK: - Initialized
    init(image: UIImage, item: Materials?) {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
        cardView.image = image
        self.item = item
        if let item = item {
            self.item = item
            self.collectButton.isSelected = CollectMaterialsCacher.shared.loads().contains(item)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: - UI properties
    let cardView = CardView(frame: CGRect(origin: .zero, size: Metric.cardViewSize))
    let textLabel = UILabel().then {
        $0.textColor = UIColor.black
        $0.font = Metric.textLableFont(size: 28)
        $0.numberOfLines = 0
        $0.isUserInteractionEnabled = true
    }
    let backButton = UIButton(type: .custom).then {
        $0.setImage(R.image.nav_item_back(), for: .normal)
        $0.sizeToFit()
    }
    let doneButton = UIButton(type: .custom).then {
        $0.setTitle("发布", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        $0.sizeToFit()
    }
    let saveButton = UIButton(type: .custom).then {
        $0.setImage(R.image.btn_save(), for: .normal)
        $0.sizeToFit()
        $0.isHidden = true
    }
    let shareButton = UIButton(type: .custom).then {
        $0.setImage(R.image.share_wechat(), for: .normal)
        $0.sizeToFit()
        $0.isHidden = true
    }
    let collectButton = UIButton(type: .custom).then {
        $0.setImage(R.image.btn_collection_normal(), for: .normal)
        $0.setImage(R.image.btn_collection_sel(), for: .selected)
        $0.sizeToFit()
        $0.isHidden = true
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
        self.backButton.rx.tap
            .bind(to: rx.dismiss())
            .disposed(by: disposeBag)
        
        toolBar.currentSelected
            .subscribe(onNext: { [unowned self] (item) in
                self.toolBarSel = item
                switch item {
                case .text:
                    self.toolBarStyleItemView.removeFromSuperview()
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
        
        Observable
            .combineLatest(
                inputTextView.textView.rx.text.filterNil(),
                toolBar.textAlignmentObserVable
            )
            .map({ (text, alignment) -> NSAttributedString in
                var attrString: NSMutableAttributedString
                switch alignment {
                case .horizontal:
                    attrString = NSMutableAttributedString(string: text.components(separatedBy: "\n").joined())
                case .vertical:
                    let arr = Array(text)
                    attrString = NSMutableAttributedString(string: arr.map { $0.description }.joined(separator: "\n"))
                }
                attrString.addAttribute(.strokeWidth, value: -6, range: NSRange(location: 0, length: attrString.string.count))
                attrString.addAttribute(.strokeColor, value: UIColor.white, range: NSRange(location: 0, length: attrString.string.count))
                return attrString
            })
            .bind(to: textLabel.rx.attributedText)
            .disposed(by: disposeBag)
        
        toolBarStyleItemView.colorSwitchView
            .colorSelectedBehavior
            .asObservable()
            .subscribe(onNext: { [unowned self] (color) in
                self.textLabel.textColor = color
            })
            .disposed(by: disposeBag)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(rotateGesture(_:)))
        textLabel.addGestureRecognizer(pan)
        cardView.addGestureRecognizer(rotate)
        
        toolBarStyleItemView.fontSliderView
            .rx.controlEvent(.valueChanged)
            .map { [unowned self] in self.toolBarStyleItemView.fontSliderView.fraction * 100 }
            .subscribe(onNext: { [unowned self] (value) in
                self.textLabel.font = Metric.textLableFont(size: value)
                self.panGesture(pan)
            })
            .disposed(by: disposeBag)
        
        self.saveButton.rx.tap
            .subscribe(onNext: { [unowned self] (_) in
                SaveImageTools.shared.saveImage(self.cardView.asImage(), completed: { (error) in
                    error.noneDo {
                        DispatchQueue.main.async {
                            message(.success, title: "已保存到手机相册")
                        }
                    }
                })
            })
            .disposed(by: disposeBag)
        
        let doneButtonTapped = self.doneButton.rx.tap
            .do(onNext: { [weak self] in self?.doneButton.isEnabled = false })
            .map { [weak self] in self?.cardView.asImage() }
            .observeOn(SerialDispatchQueueScheduler.init(internalSerialQueueName: "image_resize_queue"))
            .map { $0?.resizeImage(maxSize: 315) }
            .observeOn(MainScheduler.instance)
            .filterNil()
            .share()
            
        doneButtonTapped
            .flatMap { [weak self] image -> Observable<UIImage> in
//                guard let self = self else { return .empty() }
                
//                return Service.shared.upload(name: "", tid: self.item?.teleplayId ?? "", mid: self.item?.materialId ?? "", data: data).asObservable()
                
                guard reachabilityManager?.isReach == true else {
                    message(.warning, title: "哎呀，我没连上网！")
                    return .empty()
                }
                
                guard let data = image.resizeImage()?.jpegData(compressionQuality: 1) else { return .empty() }
                let a = Double(data.count)
                log.info("img length \(a/1024/1024)M")
                return Service.shared.upload(name: "", tid: "", mid: self?.item?.materialId ?? "", data: data)
                    .asObservable()
                    .map { _ in image }
            }
            .subscribe(onNext: { [weak self] (image) in
                guard let self = self else { return }
                CreationCacher.shared.add(ImageWrapper(image: image, timestamp: Date().timeIntervalSince1970))
                message(.success, title: "发布成功", body: "请在”我的创作“中进行查看")
                switch self.toolBarSel {
                case .text:
                    self.inputTextView.textView.resignFirstResponder()
                case .style:
                    UIView.animate(withDuration: 0.3, animations: {
                        self.toolBarStyleItemView.y = screenHeight
                        self.toolBar.bottom = screenHeight
                    }, completion: { (_) in
                        self.toolBarStyleItemView.removeFromSuperview()
                    })
                case .face:
                    break
                }
                self.dismiss(animated: true, completion: {
                    self.doneButton.isEnabled = true
                })
            }, onError: { [weak self] (error) in
                log.error(error)
                message(.error, title: "发布失败")
                self?.doneButton.isEnabled = true
            })
            .disposed(by: disposeBag)
        
//        doneButtonTapped
//            .subscribe(onNext: { [unowned self] (image) in
//                CreationCacher.shared.add(ImageWrapper(image: image, timestamp: Date().timeIntervalSince1970))
//                message(.success, title: "保存成功，可以在”我的创作“中查看")
//                switch self.toolBarSel {
//                case .text:
//                    self.inputTextView.textView.resignFirstResponder()
//                case .style:
//                    UIView.animate(withDuration: 0.3, animations: {
//                        self.toolBarStyleItemView.y = screenHeight
//                        self.toolBar.bottom = screenHeight
//                    }, completion: { (_) in
//                        self.toolBarStyleItemView.removeFromSuperview()
//                    })
//                case .face:
//                    break
//                }
//
//            })
//            .disposed(by: disposeBag)
        
        self.shareButton.rx.tap
            .subscribe(onNext: { [unowned self] (_) in
                Share.shareShow(controller: self, items: [self.cardView.asImage()])
            })
            .disposed(by: disposeBag)
        
        self.collectButton.rx.tap
            .map { [unowned self] in !self.collectButton.isSelected }
            .do(onNext: { [weak self] (isSelected) in
                guard let item = self?.item else { return }
                if isSelected {
                    CollectMaterialsCacher.shared.add(item)
                    message(.success, title: "已成功收藏", body: "请在“我的收藏”中进行查看")
                } else {
                    CollectMaterialsCacher.shared.remove(item)
                    message(.success, title: "已取消收藏")
                }
            })
            .bind(to: self.collectButton.rx.isSelected)
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        inputTextView.textView.resignFirstResponder()
    }
    
    // MARK: - SEL
    @objc func panGesture(_ gesture: UIPanGestureRecognizer) {
        let point = gesture.translation(in: self.cardView)
        let tx = self.textLabel.transform.tx + point.x
        let ty = self.textLabel.transform.ty + point.y
        self.textLabel.transform.tx = tx
        self.textLabel.transform.ty = ty
        gesture.setTranslation(.zero, in: self.cardView)
        if textLabel.transform.tx < 0 {
            textLabel.transform.tx = 0
        }
        if textLabel.transform.tx > cardView.width - self.textLabel.width {
            textLabel.transform.tx = cardView.width - self.textLabel.width
        }
        if textLabel.transform.ty < -cardView.height / 2 + self.textLabel.height / 2 {
            textLabel.transform.ty = -cardView.height / 2 + self.textLabel.height / 2
        }
        if textLabel.transform.ty > cardView.height / 2 - self.textLabel.height / 2 {
            textLabel.transform.ty = cardView.height / 2 - self.textLabel.height / 2
        }
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
                make.left.equalTo(20)
                make.centerY.equalTo(safeAreaNavTop/2 + statusBarHeight/2)
        }
        
        doneButton
            .mt.adhere(toSuperView: view)
            .mt.layout { (make) in
                make.right.equalTo(-20)
                make.centerY.equalTo(backButton)
        }
        
        view.insertSubview(cardView, belowSubview: backButton)
        cardView
            .mt.layout { (make) in
                make.centerX.equalToSuperview()
                make.top.equalTo(57 + statusBarHeight)
                make.size.equalTo(Metric.cardViewSize)
        }
        
        textLabel
            .mt.adhere(toSuperView: cardView)
            .mt.layout { (make) in
                make.centerY.leading.equalToSuperview()
                make.size.lessThanOrEqualTo(cardView)
        }
        
        shareButton
            .mt.adhere(toSuperView: view)
            .mt.layout { (make) in
                make.centerX.equalTo(cardView).offset((screenWidth - 30 * 2) / 3)
                make.top.equalTo(cardView.snp.bottom).offset(5)
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
                make.centerX.equalTo(cardView)
                make.centerY.equalTo(shareButton)
        }
        
        view.addSubview(self.inputTextView)
        view.addSubview(toolBar)
    }
    // MARK: - Private Functions
}
