//
//  MVVMViewController.swift
//  MVVM
//
//  Created by 张坤 on 2019/5/5.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BaseViewController: UIViewController {
    // MARK: - Properties
    
    public lazy private(set) var className: String = {
        return type(of: self).description().components(separatedBy: ".").last ?? ""
    }()
    
    public lazy var disposeBag = DisposeBag()
    
    // MARK: - Initializing
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        view.backgroundColor = .white
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        log.verbose("DEINIT: \(className)")
    }
    
    override open func didReceiveMemoryWarning() {
        log.warning("didReceiveMemoryWarning: \(className)")
    }
    
    // MARK: - Layout Constraints
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
    }
    
    open func setupConstraints() {
        // Override point
    }
    
    // MARK: Adjusting Navigation Item
    
    func adjustLeftBarButtonItem(image: UIImage? =
        nil) {
        if navigationController?.viewControllers.count ?? 0 > 1 { // pushed
            let barButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(pop))
            navigationItem.leftBarButtonItem = barButtonItem
            navigationController?
                .interactivePopGestureRecognizer?.delegate = self
            
        } else if presentingViewController != nil { // presented
            
            navigationItem.leftBarButtonItem =
                UIBarButtonItem(title: "取消",
                                style: .done,
                                target: self,
                                action: #selector(cancelButtonDidTap))
        }
    }
    
    @objc open func cancelButtonDidTap() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc public func pop() {
        navigationController?.popViewController(animated: true)
    }
}

extension Reactive where Base: BaseViewController {
    func pop() -> Binder<Void> {
        return Binder<Void>.init(base, binding: { (vc, _) in
            vc.navigationController?.popViewController(animated: true)
        })
    }
    
    func dismiss() -> Binder<Void> {
        return Binder<Void>.init(base, binding: { (vc, _) in
            vc.dismiss(animated: true, completion: nil)
        })
    }
}

extension BaseViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let viewControllersCount = navigationController?.viewControllers.count,
            viewControllersCount > 1 {
            return true
        } else {
            return false
        }
    }
}
