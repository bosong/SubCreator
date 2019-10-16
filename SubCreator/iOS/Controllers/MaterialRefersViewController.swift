//
//  MaterialRefersViewController.swift
//  SubCreator
//
//  Created by rpple_k on 2019/8/26.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources
import Kingfisher
import MJRefresh

class MaterialRefersViewController: BaseViewController, ReactorKit.View {
    typealias Metric = HomepageViewController.Metric
    // MARK: - Properties
    private var maxAnimateIp = IndexPath(item: 0, section: 0)
    
    // MARK: - Initialized
    init(reactor: MaterialRefersViewReactor, title: String) {
        defer { self.reactor = reactor }
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - UI properties
    let titleView = HomePageTitleView("")
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: self.flowLayout)
        cv.backgroundColor = .white
        cv.registerItemClass(HomePageCollectionViewCell.self)
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
        layout.itemSize = Metric.itemSize
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        return layout
    }()
    
    // MARK: - View Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hero.isEnabled = true
        let close = UIBarButtonItem(image: R.image.nav_item_back(), style: .done, target: self, action: #selector(pop))
        navigationItem.leftBarButtonItems = [close, UIBarButtonItem(customView: titleView)]
    }
    
    // MARK: - SEL
    
    func bind(reactor: MaterialRefersViewReactor) {
        reactor.action.onNext(.loadData)
        
        collectionView.mj_header.rx.event
            .map { _ in Reactor.Action.loadData }
            .do(onNext: { [unowned self] (_) in
                self.maxAnimateIp = IndexPath(item: 0, section: 0)
            })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        collectionView.mj_footer.rx.event
            .map { _ in Reactor.Action.loadMore }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isLoading }
            .bind(to: collectionView.mj_header.rx.endRefresh)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isLoading }
            .bind(to: collectionView.mj_footer.rx.endRefresh)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.data }
            .do(onNext: { [unowned self] in
                self.empty(show: $0.isEmpty)
            })
            .bind(to: collectionView.rx
                .items(cellIdentifier: getClassName(HomePageCollectionViewCell.self), cellType: HomePageCollectionViewCell.self)
            ) { _, model, cell in
                cell.imgV.kf.setImage(with: URL(string: model.url))
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.willDisplayCell
            .subscribe(onNext: { (cell, ip) in
                guard ip > self.maxAnimateIp else { return }
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
                self.maxAnimateIp = ip
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { [unowned self] (ip) in
                let cell = self.collectionView.cellForItem(at: ip) as? HomePageCollectionViewCell
                guard let image = cell?.imgV.image else { return }
                cell?.hero.id = "homepageCell\(ip.section)\(ip.item)"
                
                let subCreatorVC = SubCreatorViewController(image: image, item: reactor.currentState.data[ip.item])
                subCreatorVC.cardView.hero.id = cell?.hero.id
//                subCreatorVC.backButton.hero.id = cell?.hero.id
//                subCreatorVC.doneButton.hero.id = cell?.hero.id
//                subCreatorVC.saveButton.hero.id = cell?.hero.id
//                subCreatorVC.shareButton.hero.id = cell?.hero.id
//                subCreatorVC.collectButton.hero.id = cell?.hero.id
                self.present(subCreatorVC, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
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
}
