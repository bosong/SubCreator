//
//  UITableView+Ex.swift
//  MVVM
//
//  Created by 张坤 on 2019/5/13.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import UIKit

public func getClassName<T>(_ className: T.Type) -> String {
    return String(describing: className).components(separatedBy: ".").last ?? ""
}

extension UITableView {
    
    public func dequeueCell<T: UITableViewCell>(_ cellClass: T.Type) -> T {
        // swiftlint:disable force_cast
        return dequeueReusableCell(withIdentifier: getClassName(cellClass)) as! T
    }
    
    public func dequeueCell<T: UITableViewCell>(_ cellClass: T.Type,
                                                for indexPath: IndexPath) -> T {
        let identifier = getClassName(cellClass)
        return dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! T
    }
    
    public func dequeueHeaderFooterView<T: UITableViewHeaderFooterView>(_ viewClass: T.Type) -> T {
        return dequeueReusableHeaderFooterView(withIdentifier: getClassName(viewClass)) as! T
    }
    
    public func registerCellClass<T: UITableViewCell>(_ cellClass: T.Type) {
        let identifier = getClassName(cellClass)
        register(cellClass, forCellReuseIdentifier: identifier)
    }
    
    public func registerCellNib<T: UITableViewCell>(_ nibName: String? = nil, cellNib: T.Type) {
        let identifier = getClassName(cellNib)
        let bundle = Bundle(for: cellNib)
        let nib = UINib(nibName: identifier, bundle: bundle)
        register(nib, forCellReuseIdentifier: identifier)
    }
    
    public func registerHeaderFooterViewClass<T: UIView>(_ viewClass: T.Type) {
        let identifier = getClassName(viewClass)
        register(viewClass, forHeaderFooterViewReuseIdentifier: identifier)
    }
    
    public func registerHeaderFooterViewNib<T: UIView>(_ viewNib: T.Type) {
        let identifier = getClassName(viewNib)
        let bundle = Bundle(for: viewNib)
        let nib = UINib(nibName: identifier, bundle: bundle)
        register(nib, forHeaderFooterViewReuseIdentifier: identifier)
    }
}
