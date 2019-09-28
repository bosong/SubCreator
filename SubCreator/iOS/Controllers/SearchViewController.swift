//
//  SearchViewController.swift
//  SubCreator
//
//  Created by ripple_k on 2019/9/25.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import ReactorKit

class SearchViewController: BaseViewController, View {
    enum From {
        case subtitle
        case material
    }
    
    // MARK: - Properties
    let from: From
    
    // MARK: - Initialized
    init(from: From) {
        self.from = from
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI properties
    let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 260, height: 30))
    let tableView = UITableView()
    let historyView = SearchHistoryView()
    let historyCache = SearchHistoryCacher.shared
    
    // MARK: - View Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        adjustLeftBarButtonItem()
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "输入您想要搜索的影视名称"
        if let searchField = searchBar.value(forKey: "_searchField") as? UITextField {
            searchField.leftViewMode = .never
        }
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: R.image.bar_item_search(), style: .done, target: self, action: #selector(searchClicked))]
        self.navigationItem.titleView = searchBar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adjustLeftBarButtonItem()
        navigationController?.view.setNeedsLayout()
        navigationController?.view.layoutIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.view.setNeedsLayout()
        navigationController?.view.layoutIfNeeded()
    }
    
    func bind(reactor: SearchViewReactor) {
        historyView.historySelectedObservable
            .bind(to: searchBar.rx.text)
            .disposed(by: disposeBag)
        
        historyView.historySelectedObservable
            .flatMapLatest { Observable.just(Reactor.Action.search(keyword: $0)) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        historyView.historySelectedObservable
            .map { _ in false }
            .bind(to: tableView.rx.isHidden)
            .disposed(by: disposeBag)

        historyView.historySelectedObservable
            .map { _ in true }
            .bind(to: historyView.rx.isHidden)
            .disposed(by: disposeBag)
        
        searchBar.rx.text
            .filterNil()
            .flatMapLatest { Observable.just(Reactor.Action.search(keyword: $0)) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        searchBar.rx.text
            .map { $0?.isEmpty }
            .filterNil()
            .do(onNext: { [weak self] _ in self?.empty(show: false) })
            .bind(to: tableView.rx.isHidden)
            .disposed(by: disposeBag)
        
        searchBar.rx.text
            .map { $0?.isNotEmpty }
            .filterNil()
            .do(onNext: { [weak self] (bool) in
                if !bool, let data = self?.historyCache.loads() {
                    let history = data.sorted(by: { $0.timestamp > $1.timestamp }).map { $0.teleplayName }
                    self?.historyView.historys.accept(history)
                }
            })
            .bind(to: historyView.rx.isHidden)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.result }
            .do(onNext: { [weak self] (data) in
                if self?.searchBar.text?.isNotEmpty ?? false {
                    self?.empty(show: data.isEmpty)
                    self?.tableView.isHidden = data.isEmpty
                }
            })
            .bind(to: tableView.rx.items(cellIdentifier: getClassName(UITableViewCell.self), cellType: UITableViewCell.self)) { ip, element, cell in
                cell.textLabel?.text = element.teleplayName
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(SearchResult.self)
            .subscribe(onNext: { [weak self] (model) in
                var model = model
                guard let self = self else { return }
                var detailVC: UIViewController
                switch self.from {
                case .material:
                    detailVC = MaterialRefersViewController(reactor: MaterialRefersViewReactor(id: model.teleplayId))
                case .subtitle:
                    detailVC = SubtitleRefersViewController(reactor: SubtitleRefersViewReactor(id: model.teleplayId))
                }
                if self.historyCache.loads().contains(model) {
                    self.historyCache.remove(model)
                }
                model.timestamp = Date().timeIntervalSince1970
                self.historyCache.add(model)
                self.navigationController?.pushViewController(detailVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        historyView.clearButton.rx.tap
            .flatMap { [weak self] _ -> Observable<Int> in
                guard let self = self else { return .empty() }
                return UIAlertController.present(in: self,
                                                 title: "提示",
                                                 message: "你确定要清空历史记录吗？",
                                                 style: .alert,
                                                 actions: [
                                                    UIAlertController.AlertAction.action(title: "确定"),
                                                    UIAlertController.AlertAction.action(title: "取消", style: .cancel)
                    ])
            }
            .filter { $0 == 0 }
            .subscribe(onNext: { [weak self] (_) in
                self?.historyCache.clear()
                if let data = self?.historyCache.loads() {
                    let history = data.map { $0.teleplayName }
                    self?.historyView.historys.accept(history)
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - SEL
    @objc func searchClicked() {
        
    }
    
    // MARK: - Private Functions
    override func setupConstraints() {
        tableView
            .then {
                $0.registerCellClass(UITableViewCell.self)
                $0.rowHeight = 44
            }
            .mt.adhere(toSuperView: view)
            .mt.layout { (make) in
                make.edges.equalToSuperview()
        }
        
        historyView
            .mt.adhere(toSuperView: view)
            .mt.layout { (make) in
                make.topMargin.equalTo(5)
                make.left.right.bottom.equalToSuperview()
        }
    }
}

class SearchHistoryView: BaseView {
    let historys = BehaviorRelay<[String]>(value: [])
    let clearButton = UIButton(type: .custom)
    lazy var historySelectedObservable: Observable<String> = self.historySelected.asObservable().share()
    
    private let historyLabel = UIButton()
    private let historySelected = PublishRelay<String>()
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewLeftAlignedLayout()
        layout.estimatedItemSize = CGSize(width: 100, height: 22)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 10, right: 20)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        return cv
    }()
    private let disposeBag = DisposeBag()
    
    override func setupSubviews() {
        historyLabel
            .mt.config { (button) in
                button.setTitle("搜索历史", for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                button.setTitleColor(UIColor.black.withAlphaComponent(0.85), for: .normal)
            }
            .mt.adhere(toSuperView: self)
            .mt.layout { (make) in
                make.leadingMargin.equalTo(20)
                make.top.equalToSuperview()
        }
        
        clearButton
            .mt.config { (button) in
                button.setTitle("清空历史", for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                button.setTitleColor(UIColor.black.withAlphaComponent(0.85), for: .normal)
            }
            .mt.adhere(toSuperView: self)
            .mt.layout { (make) in
                make.trailingMargin.equalTo(-20)
                make.top.equalToSuperview()
        }
        
        collectionView
            .mt.config { (collectionView) in
                collectionView.registerItemClass(HistoryCell.self)
            }
            .mt.adhere(toSuperView: self)
            .mt.layout { (make) in
                make.top.equalTo(clearButton.snp.bottom).offset(10)
                make.left.right.bottom.equalToSuperview()
        }
        
        collectionView.rx.modelSelected(String.self)
            .bind(to: historySelected)
            .disposed(by: disposeBag)
        
        historys.asObservable()
            .bind(to: collectionView.rx.items(cellIdentifier: getClassName(HistoryCell.self), cellType: HistoryCell.self)) { ip, element, cell in
//                cell.label.text = element
                cell.label.setTitle(element, for: .normal)
            }
            .disposed(by: disposeBag)
    }
}

private class HistoryCell: BaseCollectionViewCell {
    let label = UIButton()
    override func setupSubviews() {
        label
            .mt.config({ (button) in
                button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                button.setTitleColor(UIColor(hex: 0xB3B3B3), for: .normal)
                button.borderWidth = 1
                button.borderColor = UIColor(hex: 0xB3B3B3)
                button.setTitle("已", for: .normal)
                button.sizeToFit()
                button.layerCornerRadius = button.height / 2
                button.isUserInteractionEnabled = false
            })
            .mt.adhere(toSuperView: contentView)
            .mt.layout { (make) in
                make.edges.equalToSuperview()
        }
    }
}
