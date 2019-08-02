//
//  TaskViewController.swift
//  SubCreator
//
//  Created by rpple_k on 2019/8/1.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class TaskViewController: BaseViewController {
    typealias Section = AnimatableSectionModel<String, TaskModel>
    
    // MARK: - Properties
    private lazy var dataSource = self.dataSourceCreator()
    private lazy var taskList = BehaviorRelay<[Section]>(value: [])
    private lazy var sections = ["section-1", "section-2", "section-3"]
    private lazy var sectionItems = ["item-1", "item-2", "item-3"]
    
    // MARK: - Initialized
    
    // MARK: - UI properties
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.registerCellClass(UITableViewCell.self)
        tableView.registerHeaderFooterViewClass(SectionHeader.self)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
//        tableView.rowHeight = 90
        return tableView
    }()
    
    // MARK: - View Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        taskList
            .asDriver()
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
//        taskList
//            .asObservable()
//            .bind(to: tableReloadEvent)
//            .disposed(by: disposeBag)
        
//        tableReloadEvent
//            .subscribe(onNext: { (sections) in
//                for i in 0..<sections.count {
//                    let img = R.image.bg_table_section_header()
//                    let borderView = UIImageView(image: img)
//                    let sectionRect = self.tableView.rect(forSection: i)
//                    borderView.frame = sectionRect
//                    self.tableView.insertSubview(borderView, at: 0)
//                }
//            })
//            .disposed(by: disposeBag)
        var items: [TaskModel] = []
        for i in 0...10 {
            var model = TaskModel()
            model.identity = "\(i)"
            items.append(model)
        }
        taskList.accept([Section(model: "section1", items: items)])
    }
    
    // MARK: - SEL
    override func setupConstraints() {
        tableView
            .mt.adhere(toSuperView: view)
            .mt.layout { (make) in
                make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Private Methods
    private func dataSourceCreator() -> RxTableViewSectionedAnimatedDataSource<Section> {
        let animationConfig = AnimationConfiguration(insertAnimation: .automatic, reloadAnimation: .automatic, deleteAnimation: .automatic)
        let decideViewTransition: RxTableViewSectionedAnimatedDataSource<Section>.DecideViewTransition = { dataSource, tableView, changset in
            return .animated
        }
        let configCell: TableViewSectionedDataSource<Section>.ConfigureCell = { datasource, tableView, indexPath, element in
            let cell = tableView.dequeueCell(UITableViewCell.self)
            cell.backgroundColor = .clear
//            self.addBgViewForTableSection(indexPath.section)
            cell.textLabel?.text = element.identity
            return cell
        }
        
        return RxTableViewSectionedAnimatedDataSource<Section>
            .init(animationConfiguration: animationConfig,
                  decideViewTransition: decideViewTransition,
                  configureCell: configCell)
    }
    
    private func addBgViewForTableSection(_ section: Int) {
        tableView.subviews.forEach { (subview) in
            if subview.tag == section + 1000 {
                subview.removeFromSuperview()
            }
        }
        let sectionFrame = tableView.rect(forSection: section)
        let img = R.image.bg_table_section()
        let borderView = UIImageView(frame: sectionFrame)
        borderView.image = UIImage.resizable().color(UIColor.mt.theme).image
        borderView.tag = section + 1000
        tableView.addSubview(borderView)
        tableView.sendSubviewToBack(borderView)
    }
}

// MARK: - UITableViewDelegate
extension TaskViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView = tableView.dequeueHeaderFooterView(SectionHeader.self)
        sectionView.title.text = "Section"
        sectionView
            .tap.rx.event
            .subscribe(onNext: { [unowned self] (_) in
                var sections = self.taskList.value
                var items: [TaskModel] = []
                for i in 0...10 {
                    var model = TaskModel()
                    model.identity = "\(section)-\(i)"
                    items.append(model)
                }
                if sections[section].items.isEmpty {
                    sections[section].items = items
                } else {
                    sections[section].items = []
                }
                self.taskList.accept(sections)
                if sections[section].items.isEmpty {
                    tableView.subviews.forEach({ (subview) in
                        if subview.tag == section + 1000 {
                            subview.removeFromSuperview()
                        }
                    })
                }
            })
            .disposed(by: sectionView.reuseDisposeBag)
        return sectionView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataSource[indexPath].isShow = !dataSource[indexPath].isShow
        tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = dataSource[indexPath]
        return model.isShow ? model.showHeight : model.rowHeight
    }
}

class SectionHeader: UITableViewHeaderFooterView {
    let title = UILabel()
    let tap = UITapGestureRecognizer()
    
    private(set) var reuseDisposeBag = DisposeBag()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupSubviews()
        contentView.addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func setupSubviews() {
        title
            .mt.adhere(toSuperView: contentView)
            .mt.layout { (make) in
                make.center.equalToSuperview()
        }
    }
}

struct TaskModel: IdentifiableType, Equatable {
    var identity = ""
    var isShow = false
    var rowHeight: CGFloat = 70
    var showHeight: CGFloat = 200
}
