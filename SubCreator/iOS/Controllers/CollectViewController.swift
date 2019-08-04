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

class CollectViewController: BaseViewController, ReactorKit.View {

    // MARK: - Properties
    // MARK: - Initialized
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
        layout.itemSize = CGSize(width: (screenWidth - 11 * 2 - 15 * 2) / 3, height: (screenWidth - 11 * 2 - 15 * 2) / 3)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        return layout
    }()
    let heroId = "collect"
    // MARK: - View Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        let heroView = UIView()
        heroView.hero.id = heroId
        view.addSubview(heroView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adjustLeftBarButtonItem()
    }
    
    // MARK: - SEL
    func bind(reactor: CollectViewReactor) {
        if reactor.currentState.type == .collect {
            title = "我的收藏"
            reactor.state.map { $0.collectData }
                .do(onNext: { [unowned self] in
                    self.empty(show: $0.isEmpty)
                })
                .bind(to: collectionView.rx
                    .items(cellIdentifier: getClassName(HomePageCollectionViewCell.self), cellType: HomePageCollectionViewCell.self)
                ) { _, model, cell in
                    cell.imgV.kf.setImage(with: URL(string: model.url))
                }
                .disposed(by: disposeBag)
        } else {
            title = "我的创作"
            reactor.state.map { $0.creationData }
                .do(onNext: { [unowned self] in
                    self.empty(show: $0.isEmpty)
                })
                .bind(to: collectionView.rx
                    .items(cellIdentifier: getClassName(HomePageCollectionViewCell.self), cellType: HomePageCollectionViewCell.self)
                ) { _, model, cell in
                    cell.imgV.image = model.image
                }
                .disposed(by: disposeBag)
        }
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { [unowned self] (ip) in
                let cell = self.collectionView.cellForItem(at: ip) as? HomePageCollectionViewCell
                guard let image = cell?.imgV.image else { return }
                
                cell?.hero.id = "homepageCell\(ip.item)"
                var item: HomeItem?
                
                if reactor.currentState.type == .collect {
                    item = reactor.currentState.collectData[ip.item]
                }
                
                let detailVC = DetailViewController(image: image, item: item)
                detailVC.shareButton.hero.id = self.heroId
                detailVC.saveButton.hero.id = self.heroId
                detailVC.collectButton.hero.id = self.heroId
                detailVC.cardView.hero.id = cell?.hero.id
                detailVC.subCreatorButton.isHidden = reactor.currentState.type == .creation
                
                self.present(detailVC, animated: true, completion: nil)
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
