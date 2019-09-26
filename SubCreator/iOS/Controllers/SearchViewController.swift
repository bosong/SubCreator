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
    let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 277, height: 30))
    let tableView = UITableView()
    
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
    }
    
    func bind(reactor: SearchViewReactor) {
        searchBar.rx.text
            .filterNil()
            .flatMapLatest { Observable.just(Reactor.Action.search(keyword: $0)) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.result }
            .bind(to: tableView.rx.items(cellIdentifier: getClassName(UITableViewCell.self), cellType: UITableViewCell.self)) { ip, element, cell in
                cell.textLabel?.text = element.teleplayName
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] (ip) in
                self?.tableView.deselectRow(at: ip, animated: true)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(SearchResult.self)
            .subscribe(onNext: { [weak self] (model) in
                guard let self = self else { return }
                var detailVC: UIViewController
                switch self.from {
                case .material:
                    detailVC = MaterialRefersViewController(reactor: MaterialRefersViewReactor(id: model.teleplayId))
                case .subtitle:
                    detailVC = SubtitleRefersViewController(reactor: SubtitleRefersViewReactor(id: model.teleplayId))
                }
                self.navigationController?.pushViewController(detailVC, animated: true)
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
    }
}
