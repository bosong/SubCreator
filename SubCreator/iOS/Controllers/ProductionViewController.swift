//
//  ProductionViewController.swift
//  SubCreator
//
//  Created by ripple_k on 2019/9/24.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

class ProductionViewController: BaseViewController, View {
    // MARK: - Properties
    // MARK: - Initialized
    private var isItemEdit = false
    private var selectedIp: [IndexPath] = [] {
        didSet {
            self.deleteButton.isEnabled = self.selectedIp.isNotEmpty
        }
    }
    
    // MARK: - UI properties
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
        layout.itemSize = HomepageViewController.Metric.itemSize
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        return layout
    }()
    lazy var deleteButton = UIButton(type: .custom)
    let heroId = "production"
    
    // MARK: - View Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        let heroView = UIView()
        heroView.hero.id = heroId
        view.addSubview(heroView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "选择", style: .done, target: self, action: #selector(editItemClick))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adjustLeftBarButtonItem()
    }
    
    func bind(reactor: ProductionViewReactor) {
        title = "我的创作"
        reactor.state.map { $0.creationData }
            .do(onNext: { [unowned self] in
                self.empty(show: $0.isEmpty)
                self.selectedIp = []
                self.isItemEdit = false
                self.deleteButton.isHidden = true
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "选择", style: .done, target: self, action: #selector(self.editItemClick))
            })
            .bind(to: collectionView.rx
                .items(cellIdentifier: getClassName(HomePageCollectionViewCell.self), cellType: HomePageCollectionViewCell.self)
            ) { [weak self] ip, model, cell in
                cell.imgV.image = model.image
                cell.isSel = self?.selectedIp.contains(IndexPath(item: ip, section: 0)) ?? false
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] (ip) in
                guard let self = self else { return }
                guard self.isItemEdit else { return }
                guard let cell = self.collectionView.cellForItem(at: ip)  as? HomePageCollectionViewCell else { return }
                cell.isSel = !self.selectedIp.contains(ip)
                if cell.isSel {
                    self.selectedIp.append(ip)
                } else {
                    if let idx = self.selectedIp.firstIndex(of: ip) {
                        self.selectedIp.remove(at: idx)
                    }
                }
                self.collectionView.reloadItems(at: [ip])
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] (ip) in
                guard let self = self else { return }
                guard !self.isItemEdit else { return }
                let cell = self.collectionView.cellForItem(at: ip) as? HomePageCollectionViewCell
                guard let image = cell?.imgV.image else { return }
                cell?.hero.id = "homepageCell\(ip.section)\(ip.item)"
                let detailVC = DetailViewController(image: image, item: nil)
                detailVC.hideReport = true
                detailVC.cardView.hero.id = cell?.hero.id
                detailVC.shareButton.hero.id = cell?.hero.id
                detailVC.saveButton.hero.id = cell?.hero.id
                detailVC.collectButton.hero.id = cell?.hero.id
                detailVC.modalPresentationStyle = .overFullScreen
                self.present(detailVC, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        deleteButton.rx.tap
            .flatMap { [weak self] _ -> Observable<Int> in
                guard let self = self else { return .empty() }
                return UIAlertController.present(in: self,
                                                 title: "提示",
                                                 message: "你确定要删除吗？",
                                                 style: .alert,
                                                 actions: [
                                                    UIAlertController.AlertAction.action(title: "确定"),
                                                    UIAlertController.AlertAction.action(title: "取消", style: .cancel)
                    ])
            }
            .filter { $0 == 0 }
            .map { [unowned self] _ in Reactor.Action.delete(self.selectedIp, alert: {
                message(.success, title: "删除成功")
            }) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    // MARK: - SEL
    @objc func editItemClick() {
        isItemEdit.toggle()
        deleteButton.isHidden = !isItemEdit
        let bottomInset = safeAreaBottomMargin + 20 + deleteButton.height
        collectionView.contentInset.bottom = isItemEdit ? bottomInset : 0
        if isItemEdit {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: .done, target: self, action: #selector(editItemClick))
        } else {
            self.selectedIp = []
            self.collectionView.reloadData()
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "选择", style: .done, target: self, action: #selector(editItemClick))
        }
    }
    
    // MARK: - Layout
    override func setupConstraints() {
        collectionView
            .mt.adhere(toSuperView: view)
            .mt.layout { (make) in
                make.edges.equalToSuperview()
        }
        
        deleteButton
            .mt.config { (button) in
                button.setTitle("删除", for: .normal)
                button.setTitleColor(.white, for: .normal)
                button.setBackgroundImage(UIImage.resizable().color(UIColor.mt.theme).image, for: .normal)
                button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
                button.isHidden = true
                button.layerCornerRadius = 8
            }
            .mt.adhere(toSuperView: view)
            .mt.layout { (make) in
                make.bottom.equalTo(-safeAreaBottomMargin - 20)
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 200, height: 38))
        }
        
    }
    
    // MARK: - Private Functions

}
