//
//  CollectViewController.swift
//  SubCreator
//
//  Created by rpple_k on 2019/8/3.
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
    // MARK: - Initialized
    private lazy var dataSource = self.prepareDataSource()
    
    // MARK: - UI properties
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: self.flowLayout)
        cv.backgroundColor = .white
        cv.registerItemClass(HomePageCollectionViewCell.self)
        cv.registerforSupplementary(HomePageSectionHeaderView.self, kind: UICollectionView.elementKindSectionHeader)
        cv.registerforSupplementary(UICollectionReusableView.self, kind: UICollectionView.elementKindSectionFooter)
        let refreshHeader = MJRefreshNormalHeader()
        refreshHeader.lastUpdatedTimeLabel.isHidden = true
        cv.mj_header = refreshHeader
        cv.mj_footer = MJRefreshAutoFooter()
        return cv
    }()
    lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 1
        let itemWidth = (screenWidth - 11 * 2 - 15 * 2) / 3
        let itemHeight = itemWidth * Metric.ItemRatio
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        layout.headerReferenceSize = CGSize(width: screenWidth, height: 50)
        layout.footerReferenceSize = CGSize(width: screenWidth, height: 1)
        return layout
    }()
    let heroId = "collect"
    // MARK: - View Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        let heroView = UIView()
        heroView.hero.id = heroId
        view.addSubview(heroView)
        title = "我的收藏"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adjustLeftBarButtonItem()
    }
    
    // MARK: - SEL
    func bind(reactor: CollectViewReactor) {
        reactor.state.map { $0.data }
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
//        collectionView.rx.itemSelected
//            .subscribe(onNext: { [unowned self] (ip) in
//                let cell = self.collectionView.cellForItem(at: ip) as? HomePageCollectionViewCell
//                guard let image = cell?.imgV.image else { return }
//                
//                cell?.hero.id = "homepageCell\(ip.item)"
//                var item: Materials?
//                
//                if reactor.currentState.type == .collect {
//                    item = reactor.currentState.collectData[ip.item]
//                }
//                
//                let detailVC = DetailViewController(image: image, item: item)
//                detailVC.shareButton.hero.id = self.heroId
//                detailVC.saveButton.hero.id = self.heroId
//                detailVC.collectButton.hero.id = self.heroId
//                detailVC.cardView.hero.id = cell?.hero.id
////                detailVC.subCreatorButton.isHidden = reactor.currentState.type == .creation
//                
//                self.present(detailVC, animated: true, completion: nil)
//            })
//            .disposed(by: disposeBag)
    }
    
    // MARK: - Layout
    override func setupConstraints() {
        collectionView
            .mt.adhere(toSuperView: view)
            .mt.layout { (make) in
                make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Private Functions
    private func prepareDataSource() -> RxCollectionViewSectionedReloadDataSource<Section> {
        return RxCollectionViewSectionedReloadDataSource<Section>.init(configureCell: { (ds, cv, ip, e) -> UICollectionViewCell in
            let cell = cv.dequeueItem(HomePageCollectionViewCell.self, for: ip)
            switch e {
            case .subtitle(let model):
                cell.imgV.kf.setImage(with: URL(string: model.url))
            case .material(let model):
                cell.imgV.kf.setImage(with: URL(string: model.url))
            }
            return cell
        }, configureSupplementaryView: { (ds, cv, id, ip) -> UICollectionReusableView in
            switch id {
            case UICollectionView.elementKindSectionHeader:
                let view = cv.dequeueReusableView(HomePageSectionHeaderView.self, kind: UICollectionView.elementKindSectionHeader, for: ip)
                view.titleLabel.text = ds[ip.section].model
                return view
            default:
                let view = cv.dequeueReusableView(UICollectionReusableView.self, kind: UICollectionView.elementKindSectionFooter, for: ip)
                view.backgroundColor = UIColor(hex: 0xEFEFEF)
                return view
            }
        })
    }
}
