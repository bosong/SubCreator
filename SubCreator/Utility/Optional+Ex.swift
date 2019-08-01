//
//  Optional+Ex.swift
//  SubCreator
//
//  Created by rpple_k on 2019/8/1.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import Foundation

extension Optional {
    /// 可选值为空的时候返回 true
    public var isNone: Bool {
        switch self {
        case .none:
            return true
        case .some:
            return false
        }
    }
    
    /// 可选值非空返回 true
    public var isSome: Bool {
        return !isNone
    }
    
    public func someDo(_ closure: () throws -> Void) rethrows {
        if isSome {
            try closure()
        }
    }
    
    public func someDo(_ closure: (Wrapped) throws -> Void) rethrows {
        if let value = self {
            try closure(value)
        }
    }
    
    public func noneDo(_ closure: () throws -> Void) rethrows {
        if isNone {
            try closure()
        }
    }
    
    func or(_ other: Optional) -> Optional {
        switch self {
        case .none: return other
        case .some: return self
        }
    }
    
    func resolve(with error: @autoclosure () -> Error) throws -> Wrapped {
        switch self {
        case .none: throw error()
        case .some(let wrapped): return wrapped
        }
    }
}
