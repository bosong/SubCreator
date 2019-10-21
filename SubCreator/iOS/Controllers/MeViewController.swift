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
        case EULA
    }
    
    var tableView = UITableView().then {
        $0.registerCellClass(MeTableViewCell.self)
        $0.rowHeight = 60
        $0.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        $0.separatorColor = UIColor(hex: 0xF5F9FC)
        $0.tableFooterView = UIView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: HomePageTitleView("我的"))
        
        let cellIdentifier = getClassName(MeTableViewCell.self)
        Observable.just([Item.collect, .gallery, .EULA])
            .bind(to: tableView.rx.items(cellIdentifier: cellIdentifier, cellType: MeTableViewCell.self)) { ip, element, cell in
                switch element {
                case .collect:
                    cell.imgView.image = R.image.me_icon_collect()
                    cell.titleLabel.text = "我的收藏"
                case .gallery:
                    cell.imgView.image = R.image.me_icon_gallery()
                    cell.titleLabel.text = "我的创作"
                case .EULA:
                    cell.imgView.image = R.image.userAgreement()
                    cell.titleLabel.text = "用户协议"
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
                case .EULA:
                    if let eulaURL = R.file.eulaHtml() {
                        let webVC = WebViewController()
                        let request = URLRequest(url: eulaURL)
                        webVC.webView.loadRequest(request)
                        webVC.title = "用户协议"
                        self?.present(BaseNavigationViewController(rootViewController: webVC), animated: true, completion: nil)
                    }
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
