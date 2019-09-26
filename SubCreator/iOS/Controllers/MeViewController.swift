//
//  MeViewController.swift
//  SubCreator
//
//  Created by ripple_k on 2019/9/23.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class MeViewController: BaseViewController {
    enum Item {
        case collect
        case gallery
    }
    
    var tableView = UITableView().then {
        $0.registerCellClass(MeTableViewCell.self)
        $0.rowHeight = 50
        $0.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.tableFooterView = UIView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: HomePageTitleView("我的"))
        
        let cellIdentifier = getClassName(MeTableViewCell.self)
        Observable.just([Item.collect, .gallery])
            .bind(to: tableView.rx.items(cellIdentifier: cellIdentifier, cellType: MeTableViewCell.self)) { ip, element, cell in
                switch element {
                case .collect:
                    cell.imgView.image = R.image.me_icon_collect()
                    cell.titleLabel.text = "我的收藏"
                case .gallery:
                    cell.imgView.image = R.image.me_icon_gallery()
                    cell.titleLabel.text = "我的创作"
                }
            }
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Item.self)
            .subscribe(onNext: { [weak self] (element) in
                switch element {
                case .collect:
                    let collectVC = CollectViewController()
                    collectVC.reactor = CollectViewReactor()
                    self?.navigationController?.pushViewController(collectVC, animated: true)
                case .gallery:
                    let productionVC = ProductionViewController()
                    productionVC.reactor = ProductionViewReactor()
                    self?.navigationController?.pushViewController(productionVC, animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] ip in
                self?.tableView.deselectRow(at: ip, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    override func setupConstraints() {
        tableView
            .mt.adhere(toSuperView: view)
            .mt.layout { (make) in
                make.edges.equalToSuperview()
        }
    }
    
}

class MeTableViewCell: BaseTableViewCell {
    let imgView = UIImageView()
    let titleLabel = UILabel()
    
    override func setupSubviews() {
        imgView
            .mt.adhere(toSuperView: contentView)
            .mt.layout { (make) in
                make.leadingMargin.equalTo(20)
                make.centerY.equalToSuperview()
        }
        
        titleLabel
            .mt.adhere(toSuperView: contentView)
            .mt.config({ (label) in
                label.textColor = .black
                label.font = UIFont.systemFont(ofSize: 16)
            })
            .mt.layout { (make) in
                make.leading.equalTo(imgView.snp.trailing).offset(15)
                make.centerY.equalToSuperview()
        }
    }
}
