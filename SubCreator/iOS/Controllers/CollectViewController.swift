//
//  CollectViewController.swift
//  SubCreator
//
//  Created by ripple_k on 2019/8/3.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import ReactorKit
import Kingfisher
import MJRefresh

class CollectViewController: BaseViewController, ReactorKit.View {
    typealias Section = SectionModel<String, Item>
    typealias Metric = HomepageViewController.Metric
    
    enum Item {
        case material(Materials)
        case subtitle(Subtitles)
    }
    // MARK: - Properties
    private var isItemEdit = false
    private var selectedIp: [IndexPath] = [] {
        didSet {
            self.deleteButton.isEnabled = self.selectedIp.isNotEmpty
        }
    }
    
    // MARK: - Initialized
    private lazy var dataSource = self.prepareDataSource()
    
    // MARK: - UI properties
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: self.flowLayout)
        cv.backgroundColor = .white
        cv.registerItemClass(HomePageCollectionViewCell.self)
        cv.registerforSupplementary(HomePageSectionHeaderView.self, kind: UICollectionView.elementKindSectionHeader)
        cv.registerforSupplementary(UICollectionReusableView.self, kind: UICollectionView.elementKindSectionFooter)
        return cv
    }()
    lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 1
        layout.itemSize = Metric.itemSize
        layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        layout.headerReferenceSize = CGSize(width: screenWidth, height: 50)
        layout.footerReferenceSize = CGSize(width: screenWidth, height: 1)
        return layout
    }()
    lazy var deleteButton = UIButton(type: .custom)
    let heroId = "collect"
    // MARK: - View Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        let heroView = UIView()
        heroView.hero.id = heroId
        view.addSubview(heroView)
        title = "我的收藏"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "选择", style: .done, target: self, action: #selector(editItemClick))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adjustLeftBarButtonItem()
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
    
    func bind(reactor: CollectViewReactor) {
        reactor.state.map { $0.data }
            .do(onNext: { [unowned self] data in
                self.empty(show: data.isEmpty)
                self.selectedIp = []
                self.isItemEdit = false
                self.deleteButton.isHidden = true
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "选择", style: .done, target: self, action: #selector(self.editItemClick))
            })
            .bind(to: collectionView.rx.items(dataSource: dataSource))
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
                switch self.dataSource[ip] {
                case .subtitle(let model):
                    let detailVC = DetailViewController(image: image, item: model)
                    detailVC.hideReport = true
                    detailVC.cardView.hero.id = cell?.hero.id
                    detailVC.shareButton.hero.id = cell?.hero.id
                    detailVC.saveButton.hero.id = cell?.hero.id
                    detailVC.collectButton.hero.id = cell?.hero.id
                    detailVC.modalPresentationStyle = .overFullScreen
                    self.present(detailVC, animated: true, completion: nil)
                    detailVC.rx.deallocated
                        .map { _ in Reactor.Action.reload }
                        .bind(to: reactor.action)
                        .disposed(by: self.disposeBag)
                case .material(let model):
                    let subCreatorVC = SubCreatorViewController(image: image, item: model)
                    subCreatorVC.cardView.hero.id = cell?.hero.id
                    subCreatorVC.backButton.hero.id = cell?.hero.id
                    subCreatorVC.doneButton.hero.id = cell?.hero.id
                    subCreatorVC.saveButton.hero.id = cell?.hero.id
                    subCreatorVC.shareButton.hero.id = cell?.hero.id
                    subCreatorVC.collectButton.hero.id = cell?.hero.id
                    self.present(subCreatorVC, animated: true, completion: nil)
                    subCreatorVC.rx.deallocated
                        .map { _ in Reactor.Action.reload }
                        .bind(to: reactor.action)
                        .disposed(by: self.disposeBag)
                }
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
    private func prepareDataSource() -> RxCollectionViewSectionedReloadDataSource<Section> {
        return RxCollectionViewSectionedReloadDataSource<Section>.init(configureCell: { [weak self] (ds, cv, ip, e) -> UICollectionViewCell in
            let cell = cv.dequeueItem(HomePageCollectionViewCell.self, for: ip)
            switch e {
            case .subtitle(let model):
                cell.imgV.kf.setImage(with: URL(string: model.url))
            case .material(let model):
                cell.imgV.kf.setImage(with: URL(string: model.url))
            }
            cell.isSel = self?.selectedIp.contains(ip) ?? false
            return cell
        }, configureSupplementaryView: { (ds, cv, id, ip) -> UICollectionReusableView in
            switch id {
            case UICollectionView.elementKindSectionHeader:
                let view = cv.dequeueReusableView(HomePageSectionHeaderView.self, kind: UICollectionView.elementKindSectionHeader, for: ip)
                view.titleLabel.text = ds[ip.section].model
                view.accessbilityBtn.isHidden = true
                return view
            default:
                let view = cv.dequeueReusableView(UICollectionReusableView.self, kind: UICollectionView.elementKindSectionFooter, for: ip)
                view.backgroundColor = UIColor(hex: 0xEFEFEF)
                return view
            }
        })
    }
}
