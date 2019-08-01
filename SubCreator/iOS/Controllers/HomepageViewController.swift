//
//  HomepageViewController.swift
//  SubCreator
//
//  Created by rpple_k on 2019/7/30.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources

class HomepageViewController: BaseViewController, View {

    // MARK: - Properties
    // MARK: - Initialized
    // MARK: - UI properties
    let titleView = HomePageTitleView()
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: self.flowLayout)
        cv.backgroundColor = .white
        cv.registerItemClass(HomePageCollectionViewCell.self)
        return cv
    }()
    lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 1
        layout.itemSize = CGSize(width: (screenWidth - 11 * 2 - 15 * 2) / 3, height: (screenWidth - 11 * 2 - 15 * 2) / 3)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        return layout
    }()
    let editButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.image.homepage_btn_edit_normal(), for: .normal)
        button.setImage(R.image.homepage_btn_edit_sel(), for: .selected)
        return button
    }()
    let myCreationButton: UIButton = {
        let button = UIButton(type: .custom)
        button.isHidden = true
        button.setTitle("我的创作", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.setBackgroundImage(R.image.homepage_bg_btn(), for: .normal)
        button.sizeToFit()
        return button
    }()
    let myCollectionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.isHidden = true
        button.setTitle("我的收藏", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.setBackgroundImage(R.image.homepage_bg_btn(), for: .normal)
        button.sizeToFit()
        return button
    }()
    
    // MARK: - View Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleView)
        editButton.hero.id = "bottomButton"
    }
    
    // MARK: - SEL
    func bind(reactor: HomepageViewReactor) {
        reactor.state.map { $0.data }
            .bind(to: collectionView.rx
                .items(cellIdentifier: getClassName(HomePageCollectionViewCell.self), cellType: HomePageCollectionViewCell.self)
            ) { _, model, cell in
                cell.imgV.image = model
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.willDisplayCell
            .subscribe(onNext: { (cell, ip) in
                let col = ip.item % 3
                let delayTime = Double(col) / Double(10)
                cell.transform = CGAffineTransform(a: 0.6, b: 0, c: 0, d: 0.6, tx: -10, ty: -10)
                cell.alpha = 0.5
                DispatchQueue.main.asyncAfter(deadline: .now() + delayTime, execute: {
                    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                        cell.alpha = 1
                        cell.transform = CGAffineTransform.identity
                    })
                })
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { [unowned self] (ip) in
                let cell = self.collectionView.cellForItem(at: ip)
                cell?.hero.id = "homepageCell\(ip.item)"
                let detailVC = DetailViewController()
                detailVC.subCreatorButton.hero.id = self.editButton.hero.id
                detailVC.cardView.hero.id = cell?.hero.id
                detailVC.shareButton.hero.id = self.editButton.hero.id
                detailVC.saveButton.hero.id = self.editButton.hero.id
                detailVC.collectButton.hero.id = self.editButton.hero.id
                self.present(detailVC, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        editButton.rx.tap
            .map { [unowned self] in !self.editButton.isSelected }
            .throttle(1, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .do(onNext: { [unowned self] (isSelected) in
                self.editButtonTapped(isSelected)
            })
            .bind(to: editButton.rx.isSelected)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Layout
    override func setupConstraints() {
        collectionView
            .mt.adhere(toSuperView: view)
            .mt.layout { (make) in
                make.edges.equalToSuperview()
        }
        
        editButton
            .mt.adhere(toSuperView: view)
            .mt.layout { (make) in
                make.right.equalTo(-10)
                make.bottom.equalTo(-safeAreaBottomMargin - 30)
        }
        
        view.insertSubview(myCreationButton, belowSubview: editButton)
        myCreationButton
            .mt.layout { (make) in
                make.right.equalTo(-12)
                make.centerY.equalTo(editButton)
        }
        
        view.insertSubview(myCollectionButton, belowSubview: editButton)
        myCollectionButton
            .mt.layout { (make) in
                make.right.equalTo(-12)
                make.centerY.equalTo(editButton)
        }
    }
    
    private func editButtonTapped(_ isSelected: Bool) {
        if isSelected {
            self.myCreationButton.isHidden = !isSelected
            self.myCollectionButton.isHidden = !isSelected
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 1,
                           options: UIView.AnimationOptions.curveEaseInOut,
                           animations: {
                            self.myCollectionButton.transform = CGAffineTransform(translationX: 0, y: -65)
                            self.myCreationButton.transform = CGAffineTransform(translationX: 0, y: -110)
            })
        } else {
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 1,
                           options: UIView.AnimationOptions.curveEaseOut,
                           animations: {
                            self.myCollectionButton.transform = CGAffineTransform.identity
                            self.myCreationButton.transform = CGAffineTransform.identity
                            self.myCollectionButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                            self.myCreationButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }, completion: { (_) in
                self.myCollectionButton.transform = CGAffineTransform.identity
                self.myCreationButton.transform = CGAffineTransform.identity
                self.myCreationButton.isHidden = !isSelected
                self.myCollectionButton.isHidden = !isSelected
            })
        }
    }
    
    // MARK: - Private Functions
}

class HomePageTitleView: BaseView {
    let imgV = UIImageView()
    let titleLabel = UILabel()
    override func setupSubviews() {
        imgV
            .mt.adhere(toSuperView: self)
            .mt.config({ (imgV) in
                imgV.image = UIImage
                    .size(width: 8, height: 16)
                    .color(UIColor.mt.theme)
                    .corner(topRight: 8)
                    .corner(bottomRight: 8)
                    .image
            })
            .mt.layout { (make) in
                make.size.equalTo(CGSize(width: 8, height: 16))
                make.centerY.equalToSuperview()
                make.left.equalToSuperview()
        }
        
        titleLabel
            .mt.adhere(toSuperView: self)
            .mt.config { (label) in
                label.text = "资源库"
                label.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
                label.textColor = .black
            }
            .mt.layout { (make) in
                make.left.equalTo(imgV.snp.right).offset(8)
                make.centerY.equalToSuperview()
        }
    }
}
