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
import Kingfisher
import MJRefresh
import Fusuma

class HomepageViewController: BaseViewController, ReactorKit.View {
    private typealias Section = SectionModel<Subtitle, Subtitles>
    
    struct Metric {
        static let itemRatio: CGFloat = 2 / 3
        static let itemWidth = (screenWidth - 11 * 2 - 15 * 2) / 3
        static let itemHeight = Metric.itemWidth * Metric.itemRatio
        static let itemSize: CGSize = CGSize(width: itemWidth, height: itemHeight)
    }
    
    // MARK: - Properties
    var maxAnimateIp = IndexPath(item: 0, section: 0)
    private lazy var dataSource = self.prepareDataSource()
    
    // MARK: - Initialized
    init(reactor: HomepageViewReactor) {
        defer { self.reactor = reactor }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
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
        layout.itemSize = Metric.itemSize
        layout.estimatedItemSize = .zero
        layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        layout.headerReferenceSize = CGSize(width: screenWidth, height: 50)
        layout.footerReferenceSize = CGSize(width: screenWidth, height: 1)
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
    let uploadButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.image.btn_upload(), for: .normal)
        button.sizeToFit()
        button.isHidden = true
        return button
    }()
    
    // MARK: - View Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: HomePageTitleView("广场"))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.bar_item_search(), style: .done, target: self, action: #selector(searchClicked))
        editButton.hero.id = "bottomButton"
        uploadButton.hero.id = "uploadButton"
    }
    
    // MARK: - SEL
    func bind(reactor: HomepageViewReactor) {
        Observable.just(Reactor.Action.subtitleList)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        collectionView.mj_header.rx.event
            .map { _ in Reactor.Action.subtitleList }
            .do(onNext: { [unowned self] (_) in
                self.maxAnimateIp = IndexPath(item: 0, section: 0)
            })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        collectionView.mj_footer.rx.event
            .map { _ in Reactor.Action.subtitleListMore }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isLoading }
            .bind(to: collectionView.mj_header.rx.endRefresh)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isLoading }
            .bind(to: collectionView.mj_footer.rx.endRefresh)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.subtitle }
            .do(onNext: { [weak self] in self?.empty(show: $0.isEmpty) })
            .map { $0.map { Section(model: $0, items: $0.subtitles) } }
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        collectionView.rx.willDisplayCell
            .subscribe(onNext: { [weak self] (cell, ip) in
                guard let self = self else { return }
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
//            .do(onNext: { [unowned self] _ in
//                self.editButtonTapped(false)
//            })
            .subscribe(onNext: { [unowned self] (ip) in
                let cell = self.collectionView.cellForItem(at: ip) as? HomePageCollectionViewCell
                guard let image = cell?.imgV.image else { return }
                cell?.hero.id = "homepageCell\(ip.section)\(ip.item)"
                let detailVC = DetailViewController(image: image, item: self.dataSource[ip])
                detailVC.cardView.hero.id = cell?.hero.id
                detailVC.shareButton.hero.id = self.uploadButton.hero.id
                detailVC.saveButton.hero.id = self.uploadButton.hero.id
                detailVC.collectButton.hero.id = self.uploadButton.hero.id
                detailVC.modalPresentationStyle = .overFullScreen
                self.present(detailVC, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.prefetchItems
            .map { [unowned self] in $0.compactMap { URL(string: self.dataSource[$0].url) } }
            .subscribe(onNext: { ImagePrefetcher(urls: $0).start() })
            .disposed(by: disposeBag)
        
        collectionView.rx.cancelPrefetchingForItems
            .map { [unowned self] in $0.compactMap { URL(string: self.dataSource[$0].url) } }
            .subscribe(onNext: { ImagePrefetcher(urls: $0).stop() })
            .disposed(by: disposeBag)
        
//        editButton.rx.tap
//            .map { [unowned self] in !self.editButton.isSelected }
//            .throttle(0.6, scheduler: MainScheduler.instance)
//            .subscribe(onNext: { [unowned self] (isSelected) in
//                self.editButtonTapped(isSelected)
//            })
//            .disposed(by: disposeBag)
//
//        Observable.merge(
//            myCollectionButton.rx.tap.asObservable(),
//            myCreationButton.rx.tap.asObservable()
//            )
//            .subscribe(onNext: { [unowned self] (_) in
//                self.editButtonTapped(false)
//            })
//            .disposed(by: disposeBag)
//
//        myCreationButton.rx.tap
//            .subscribe(onNext: { [unowned self] (_) in
//                let collectVC = CollectViewController()
//                collectVC.reactor = CollectViewReactor(.creation)
//                self.navigationController?.pushViewController(collectVC, animated: true)
//            })
//            .disposed(by: disposeBag)
//
//        myCollectionButton.rx.tap
//            .subscribe(onNext: { (_) in
//                let collectVC = CollectViewController()
//                collectVC.reactor = CollectViewReactor(.collect)
//                self.navigationController?.pushViewController(collectVC, animated: true)
//            })
//            .disposed(by: disposeBag)
    }
    
    @objc func searchClicked() {
        let searchVC = SearchViewController(from: .subtitle)
        searchVC.reactor = SearchViewReactor()
        navigationController?.pushViewController(searchVC, animated: true)
    }
    
    // MARK: - Layout
    override func setupConstraints() {
        collectionView
            .mt.adhere(toSuperView: view)
            .mt.layout { (make) in
                make.edges.equalToSuperview()
        }
        
        uploadButton
            .mt.adhere(toSuperView: view)
            .mt.layout { (make) in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(uploadButton.height)
        }
        
//        editButton
//            .mt.adhere(toSuperView: view)
//            .mt.layout { (make) in
//                make.right.equalTo(-10)
//                make.bottom.equalTo(-safeAreaBottomMargin - 30)
//        }
//
//        view.insertSubview(myCreationButton, belowSubview: editButton)
//        myCreationButton
//            .mt.layout { (make) in
//                make.right.equalTo(-12)
//                make.centerY.equalTo(editButton)
//        }
//
//        view.insertSubview(myCollectionButton, belowSubview: editButton)
//        myCollectionButton
//            .mt.layout { (make) in
//                make.right.equalTo(-12)
//                make.centerY.equalTo(editButton)
//        }
    }
    
    private func editButtonTapped(_ isSelected: Bool) {
        self.editButton.isSelected = isSelected
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
                            self.myCollectionButton.alpha = 0
                            self.myCreationButton.alpha = 0
            }, completion: { (_) in
                self.myCollectionButton.alpha = 1
                self.myCreationButton.alpha = 1
                self.myCollectionButton.transform = CGAffineTransform.identity
                self.myCreationButton.transform = CGAffineTransform.identity
                self.myCreationButton.isHidden = !isSelected
                self.myCollectionButton.isHidden = !isSelected
            })
        }
    }
    
    // MARK: - Private Functions
    private func prepareDataSource() -> RxCollectionViewSectionedReloadDataSource<Section> {
        return RxCollectionViewSectionedReloadDataSource<Section>.init(configureCell: { (ds, cv, ip, e) -> UICollectionViewCell in
            let cell = cv.dequeueItem(HomePageCollectionViewCell.self, for: ip)
            cell.imgV.kf.setImage(with: URL(string: e.url))
            return cell
        }, configureSupplementaryView: { (ds, cv, id, ip) -> UICollectionReusableView in
            switch id {
            case UICollectionView.elementKindSectionHeader:
                let view = cv.dequeueReusableView(HomePageSectionHeaderView.self, kind: UICollectionView.elementKindSectionHeader, for: ip)
                view.titleLabel.text = ds[ip.section].model.teleplayName
                view.accessbilityBtn.rx.tap
                    .subscribe(onNext: { [weak self] _ in
                        let moreVC = SubtitleRefersViewController(reactor: SubtitleRefersViewReactor(id: ds[ip.section].model.teleplayId))
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

class HomePageSectionHeaderView: UICollectionReusableView {
    let imgV = UIImageView()
    let titleLabel = UILabel()
    let accessbilityBtn = UIButton(type: .custom)
    
    private(set) var reuseDisposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        prepareSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseDisposeBag = DisposeBag()
    }
    
    private func prepareSubviews() {
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
                make.left.equalTo(15)
        }
        
        titleLabel
            .mt.adhere(toSuperView: self)
            .mt.config { (label) in
                label.text = "资源库"
                label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
                label.textColor = UIColor(hex: 0x4F3B04)
            }
            .mt.layout { (make) in
                make.left.equalTo(imgV.snp.right).offset(5)
                make.centerY.equalToSuperview()
        }
        
        accessbilityBtn
            .mt.adhere(toSuperView: self)
            .mt.config { (btn) in
                btn.setImage(R.image.homepage_accessbility(), for: .normal)
            }
            .mt.layout { (make) in
                make.right.equalTo(-15)
                make.centerY.equalToSuperview()
        }
    }
}

class HomePageTitleView: BaseView {
    let titleLabel = UILabel()
    
    init(_ title: String) {
        super.init(frame: .zero)
        self.titleLabel.text = title
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupSubviews() {
        titleLabel
            .mt.adhere(toSuperView: self)
            .mt.config { (label) in
                label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
                label.textColor = .black
            }
            .mt.layout { (make) in
                make.left.equalToSuperview()
                make.centerY.equalToSuperview()
        }
    }
}
