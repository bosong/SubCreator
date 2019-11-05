//
//  NSObject+Ex.swift
//  SubCreator
//
//  Created by ripple_k on 2019/10/31.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import Foundation

extension NSObject {
    func getIvar(name: String) -> Any? {
        guard let _var = class_getInstanceVariable(type(of: self), name) else {
            return nil
        }

        return object_getIvar(self, _var)
    }
}
