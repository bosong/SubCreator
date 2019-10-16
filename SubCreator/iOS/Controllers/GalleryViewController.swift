//
//  GalleryViewController.swift
//  SubCreator
//
//  Created by ripple_k on 2019/9/23.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import Foundation
import Fusuma
import RxSwift
import RxCocoa
import RxDataSources
import Kingfisher

class GalleryViewControler: HomepageViewController {
    typealias Section = SectionModel<Material, Materials>
    // MARK: - Properties
    
    lazy var dataSource = self.prepareDataSource()
    
    // MARK: - Initialized
    // MARK: - UI properties
    // MARK: - View Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        uploadButton.isHidden = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: HomePageTitleView("创作"))
    }
    
    private func uploadButton(show: Bool) {
        if show {
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 1,
                           options: UIView.AnimationOptions.curveEaseInOut,
                           animations: {
                            self.uploadButton.transform = CGAffineTransform(translationX: 0, y: -self.uploadButton.height - 24)
            })
        } else {
            self.uploadButton.transform = .identity
        }
    }
    
    override func bind(reactor: HomepageViewReactor) {
        TabBarController.selectedIndex
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] in self?.uploadButton(show: $0 == 1) })
            .disposed(by: disposeBag)
        
        TabBarController.selectedIndex
            .filter { $0 == 1 }
            .skip(1)
            .do(onNext: { [weak self] _ in
                self?.collectionView.contentOffset.y = 0
            })
            .map { _ in Reactor.Action.materialList }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        Observable.just(Reactor.Action.materialList)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        collectionView.mj_header.rx.event
            .map { _ in Reactor.Action.materialList }
            .do(onNext: { [unowned self] (_) in
                self.maxAnimateIp = IndexPath(item: 0, section: 0)
            })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        collectionView.mj_footer.rx.event
            .map { _ in Reactor.Action.materialListMore }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isLoading }
            .bind(to: collectionView.mj_header.rx.endRefresh)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isLoading }
            .bind(to: collectionView.mj_footer.rx.endRefresh)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.material }
            .skip(1)
            .do(onNext: { [weak self] in self?.empty(show: $0.isEmpty) })
            .map { $0.map { Section(model: $0, items: $0.materials) } }
            .bind(to: collectionView.rx.items(dataSource: dataSource))
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
        
        collectionView.rx.willDisplaySupplementaryView
            .subscribe(onNext: { (supplementaryView, elementKind, ip) in
                if elementKind == UICollectionView.elementKindSectionHeader {
                    supplementaryView.layer.zPosition = 0
                }
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { [unowned self] (ip) in
                let cell = self.collectionView.cellForItem(at: ip) as? HomePageCollectionViewCell
                guard let image = cell?.imgV.image else { return }
                cell?.hero.id = "homepageCell\(ip.section)\(ip.item)"
                
                let subCreatorVC = SubCreatorViewController(image: image, item: self.dataSource[ip])
                subCreatorVC.cardView.hero.id = cell?.hero.id
                subCreatorVC.backButton.hero.id = self.uploadButton.hero.id
                subCreatorVC.doneButton.hero.id = self.uploadButton.hero.id
                subCreatorVC.saveButton.hero.id = self.uploadButton.hero.id
                subCreatorVC.shareButton.hero.id = self.uploadButton.hero.id
                subCreatorVC.collectButton.hero.id = self.uploadButton.hero.id
                self.present(subCreatorVC, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.prefetchItems
            .map { [unowned self] in $0.compactMap { URL(string: self.dataSource[$0].url) } }
            .subscribe(onNext: { ImagePrefetcher(urls: $0).start() })
            .disposed(by: disposeBag)
        
//        collectionView.rx.cancelPrefetchingForItems
//            .map { [unowned self] in $0.compactMap { URL(string: self.dataSource[$0].url) } }
//            .subscribe(onNext: { ImagePrefetcher(urls: $0).stop() })
//            .disposed(by: disposeBag)
        
        self.uploadButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showPhoto()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - SEL
    private func showPhoto() {
        let fusuma = FusumaViewController().then { (fusuma) in
            fusuma.availableModes = [FusumaMode.library, FusumaMode.camera]
            fusuma.cropHeightRatio = Metric.itemRatio
            fusuma.allowMultipleSelection = false
            fusumaCameraRollTitle = "相册"
            fusumaCameraTitle = "拍照"
        }
        fusuma.delegate = self
        self.present(fusuma, animated: true, completion: nil)
    }
    
    override func searchClicked() {
        let searchVC = SearchViewController(from: .material)
        searchVC.reactor = SearchViewReactor()
        navigationController?.pushViewController(searchVC, animated: true)
    }
    
    // MARK: - Private Functions
    private func prepareDataSource() -> RxCollectionViewSectionedReloadDataSource<GalleryViewControler.Section> {
        return RxCollectionViewSectionedReloadDataSource<Section>.init(configureCell: { (ds, cv, ip, e) -> UICollectionViewCell in
            let cell = cv.dequeueItem(HomePageCollectionViewCell.self, for: ip)
            cell.imgV.kf.setImage(with: URL(string: e.url))
            return cell
        }, configureSupplementaryView: { (ds, cv, id, ip) -> UICollectionReusableView in
            switch id {
            case UICollectionView.elementKindSectionHeader:
                let view = cv.dequeueReusableView(HomePageSectionHeaderView.self, kind: UICollectionView.elementKindSectionHeader, for: ip)
                view.titleLabel.text = ds[ip.section].model.teleplayName
                view.tapGesture.rx.event
                    .subscribe(onNext: { [weak self] _ in
                        let moreVC = MaterialRefersViewController(reactor: MaterialRefersViewReactor(id: ds[ip.section].model.teleplayId), title: ds[ip.section].model.teleplayName)
                        self?.navigationController?.pushViewController(moreVC, animated: true)
                    })
                    .disposed(by: view.reuseDisposeBag)
                return view
            default:
                let view = cv.dequeueReusableView(UICollectionReusableView.self, kind: UICollectionView.elementKindSectionFooter, for: ip)
                view.backgroundColor = UIColor(hex: 0xEFEFEF)
                return view
            }
        })
    }
}

extension GalleryViewControler: FusumaDelegate {
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
        
    }
    
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        
    }
    
    func fusumaDismissedWithImage(_ image: UIImage, source: FusumaMode) {
        let subCreatorVC = SubCreatorViewController(image: image, item: nil)
        subCreatorVC.cardView.hero.id = self.uploadButton.hero.id
//        subCreatorVC.backButton.hero.id = self.uploadButton.hero.id
//        subCreatorVC.doneButton.hero.id = self.uploadButton.hero.id
//        subCreatorVC.saveButton.hero.id = self.uploadButton.hero.id
//        subCreatorVC.shareButton.hero.id = self.uploadButton.hero.id
//        subCreatorVC.collectButton.hero.id = self.uploadButton.hero.id
        self.present(subCreatorVC, animated: true, completion: nil)
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        
    }
    
    func fusumaCameraRollUnauthorized() {
        
    }
}
