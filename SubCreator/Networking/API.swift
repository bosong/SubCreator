//
//  API.swift
//  SubCreator
//
//  Created by rpple_k on 2019/8/3.
//  Copyright © 2019 ripple_k. All rights reserved.
//
//  swiftlint:disable type_name

import Foundation

enum API {
    case homeList(limit: Int, skip: Int)
}

extension API: APITargetType {
    var router: Router {
        return .get("/home")
    }
    
    var parameters: Parameters? {
        switch self {
        case let .homeList(limit, skip):
            return ["limit": limit, "skip": skip]
        }
    }
}
