//
//  Namespace.swift
//  MVVM
//
//  Created by 张坤 on 2019/5/5.
//  Copyright © 2019 ripple_k. All rights reserved.
//

public protocol NamespaceWrappable {
    associatedtype MVVMWrappable
    var mt: MVVMWrappable { get }
    static var mt: MVVMWrappable.Type { get }
}

public extension NamespaceWrappable {
    var mt: NamespaceWrapper<Self> {
        return NamespaceWrapper(value: self)
    }
    
    static var mt: NamespaceWrapper<Self>.Type {
        return NamespaceWrapper.self
    }
}

public struct NamespaceWrapper<T> {
    public let wrappedValue: T
    public init(value: T) {
        self.wrappedValue = value
    }
}
